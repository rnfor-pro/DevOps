variable "web_region" {
  description = "Region in which my jenkins server is going to be created"
  type        = string
  default     = "us-east-2"
}

variable "ami_id" {
  description = "My Jenkins configured as code"
  type        = string
  default     = "ami-0f30a9c3a48f3fa79"
}

variable "instance_type" {
  description = "My jenkins instance type"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "My Jenkins instance key"
  type        = string
  default     = "jcasc_key"
}

