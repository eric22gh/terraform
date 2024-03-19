variable "tags_limon" {
  description = "This is the tag of limon"
  type        = map(string)
  default = {
    region      = "us-east-1"
    environment = "dev"
    cloud       = "aws"
    owner       = "ericklimon"
    IAC_version = "1.7.3"
    IAC         = "Terraform"
    year        = "2024"
    project     = "practica-8"
  }
}


variable "cidr_block-virginia" {
  description = "This is the cidr block of virginia"
  type        = string
  default     = "192.20.0.0/18"
  sensitive   = false
}

variable "subnets" {
  description = "This is the subnets"
  type        = list(string)
  default     = ["192.20.1.0/25", "192.20.1.128/25"]
  sensitive   = false
}

variable "ami" {
  description = "This is the ami"
  type        = string
  default     = "ami-0440d3b780d96b29d"
  sensitive   = true
}

variable "instance_type" {
  description = "This is the instance type"
  type        = string
  default     = "t2.micro"
  sensitive   = false
}

# para el bucket de s3
resource "random_string" "sufijo-s3" {
  length  = 8
  special = false
  upper   = false
}
# dynamic blocks 

variable "ingress_ports" {
  description = "This is the ingress port"
  type        = list(number) # tiene q ser de este tipo xk si no da error
  default     = [22, 80, 443]
}
