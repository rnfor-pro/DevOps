
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

resource "grafana_data_source" "promethues" {
  type = var.data_source_type
  name = var.data_source_name
  url  = var.prometheus_url

  lifecycle {
    ignore_changes = [json_data_encoded, http_headers]
  }
}



# docker run -d --name=sample_grafana -p 3000:3000 -e GF_AUTH_BASIC_ENABLED=true -e GF_SECURITY_ADMIN_USER=admin -e GF_SECURITY_ADMIN_PASSWORD=admin123 grafana/grafana
