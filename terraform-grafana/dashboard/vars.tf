variable "grafana_dashboard_folder_name" {
  description = "Folder name created on grafana istance"
  type        = string
  default     = "stage"
}

variable "dashboard_file_path" {
  description = "Grafana dashboard file  local path"
  type        = string
  default     = "dashboards/"
}
variable "grafana_endpoint" {
  type        = string
  description = "Define Endpoint of Grafana"
  default     = "http://terraformgrafana.therednosehomebuyers.com:3000/"
}


variable "grafana_service_account_api_key" {
  type        = string
  description = "Define API key to conect Grafana instance"
  default     = ""
}
