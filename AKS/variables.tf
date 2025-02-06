###############################################################################
# VARIABLES
###############################################################################
variable "subscription_id" {
  type        = string
  description = "Azure subscription ID for resource deployment"
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "deployment_id" {
  type        = string
  description = "Unique identifier for the deployment to avoid resource name conflicts"
}