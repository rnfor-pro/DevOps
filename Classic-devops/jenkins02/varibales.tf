variable "ami_id" {
  description = "My Jenkins configured as code"
  type = string
  default = ""
}

variable "instance_type" {
  description = "My Jenkins instance type"
  type = string
  default = ""
}

variable "key_name" {
  description = "My Jenkins instance key"
  type = string
  default = "jcasc_key"
}