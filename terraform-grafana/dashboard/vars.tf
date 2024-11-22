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
  description = "Endpoint of Grafana service"
  default     = ""
}


variable "grafana_service_account_api_key" {
  type        = string
  description = "Endpoint of Promethues service"
  default     = ""
}


variable "prometheus_url" {
  description = "The URL for the Grafana instance"
  type        = string
  default     = ""
}

variable "data_source_name" {
  description = "The name of the Prometheus data source in Grafana"
  type        = string
  default     = "prometheus"
}

variable "data_source_type" {
  description = "The type of data source to configure in Grafana"
  type        = string
  default     = "prometheus"
}
