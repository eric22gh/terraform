#harcer 3 ec2 con diferentes nombres almacenar esos nombres en variables.
resource "aws_vpc" "vpc-limon" {
  cidr_block = var.cidr_block-virginia
  tags = {
    Name = "vpc-limon-${local.sufix}"
  }
}

resource "aws_internet_gateway" "igw-limon" {
  vpc_id = aws_vpc.vpc-limon.id
  tags = {
    Name = "igw-limon-${local.sufix}"
  }
}

resource "aws_route_table" "public-limon" {
  vpc_id = aws_vpc.vpc-limon.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-limon.id
  }
  tags = {
    Name = "RT-public-limon-${local.sufix}"
  }
}

resource "aws_route_table_association" "public-limon" {
  subnet_id      = aws_subnet.public-limon.id
  route_table_id = aws_route_table.public-limon.id
}

resource "aws_security_group" "sg-limon" {
  vpc_id = aws_vpc.vpc-limon.id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "sg-limon-${local.sufix}"
  }
}

resource "aws_subnet" "public-limon" {
  vpc_id                  = aws_vpc.vpc-limon.id
  cidr_block              = var.subnets[0]
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true # Asigna una IP pública a las instancias que se lancen en esta subred
  tags = {
    Name = "public-limon-${local.sufix}"
  }
}

resource "aws_instance" "apache-limon" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public-limon.id
  key_name               = "PER"
  vpc_security_group_ids = [aws_security_group.sg-limon.id]
  user_data              = file("scripts/apache.sh") # se pone el archivo userdata.sh en variable y se puedo utilizar para varios
  tags = {
    Name = "nginx-limon-${local.sufix}"
  }
}

resource "aws_instance" "nginx-limon" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public-limon.id
  key_name               = "PER"
  vpc_security_group_ids = [aws_security_group.sg-limon.id]
  user_data              = file("scripts/userdata.sh") # se pone el archivo userdata.sh en variable y se puedo utilizar para varios
  tags = {
    Name = "apache-limon-${local.sufix}"
  }

}

#como crear modulos 
# hay hacer una carpeta llamda modulos y poner el codigo ahi

module "mybucket" {
  source = "./modulos/s3" # se pone el path del modulo"
}
#terraform apply --target=module.mybucket.aws_s3_bucket.bucket-limon

#Terraform module that provision an S3 bucket to store the `terraform.tfstate` file and a DynamoDB table to lock the state
module "terraform_state_backend" {
  source = "cloudposse/tfstate-backend/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version    = "1.4.1"
  namespace  = "limon"
  stage      = "test"
  name       = "terraform"
  attributes = ["state"]

  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = false
}

#terraform apply --target=module.terraform_state_backend.aws_s3_bucket.terraform_state_backend
# hay que darle init cuando se pega el modulo, despues apply y para subir
# el state al bucket hay que darle terraform init
#rm -rf terraform.tfstate* para borrar el state localmente
# despues para traerlo es terraform state pull > terraform.tfstate
# para dejar de usar el state de manera remota se destruche o se comenta el file backend.tf
# y se da terraform init -migrate-state
# y despues se borra el state remoto
