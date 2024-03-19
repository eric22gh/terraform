locals {
  sufix = "${var.tags_limon["environment"]}-${var.tags_limon["owner"]}-${var.tags_limon["project"]}"
  # se usa para poner algunos values de los tags en el nombre de los recursos
  # es muy util para los buckets de s3

}

locals {
  sufijo-s3 = "${var.tags_limon["environment"]}-${var.tags_limon["owner"]}-${var.tags_limon["project"]}--${random_string.sufijo-s3.id}"
}
