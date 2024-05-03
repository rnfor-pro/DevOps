# https://jhooq.com/terraform-module/


module "jcasc" {
  source        = ".//jenkins01"
  instance_type = "t2.medium"
  ami_id        = var.ami_id
}


