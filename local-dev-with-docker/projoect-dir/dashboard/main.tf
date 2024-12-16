provider "grafana" {
  url  = var.grafana_endpoint
  auth = var.grafana_service_account_api_key
}

resource "grafana_folder" "create_folder_on_grafana" {
  title = var.grafana_dashboard_folder_name
}

resource "grafana_dashboard" "deploy_dashboard" {
  for_each    = fileset("${var.dashboard_file_path}", "**")
  config_json = file("${var.dashboard_file_path}/${each.key}")
  folder      = grafana_folder.create_folder_on_grafana.id
}