resource "grafana_folder" "digital-entdevs-obsevltyg-dev-001" {
  title = var.digital-entdevs-obsevltyg-dev-001
}

resource "grafana_folder" "digital-entdevs-obsevltyg-dev-002" {
  title = var.digital-entdevs-obsevltyg-dev-002
}

resource "grafana_dashboard" "deploy_dashboard" {
  for_each    = fileset("${var.dashboard_file_path}", "**")
  config_json = file("${var.dashboard_file_path}/${each.key}")
  folder      = "grafana_folder.digital-entdevs-obsevltyg-dev-001.id"
}

resource "grafana_data_source" "prometheus" {
  type = var.data_source_type
  name = var.data_source_name
  url  = var.prometheus_url

  lifecycle {
    ignore_changes = [json_data_encoded, http_headers]
  }
}


resource "grafana_dashboard" "test" {
  config_json = "{}" # Placeholder, this will be overwritten after import
}











# docker run -d --name=sample_grafana -p 3000:3000 -e GF_AUTH_BASIC_ENABLED=true -e GF_SECURITY_ADMIN_USER=admin -e GF_SECURITY_ADMIN_PASSWORD=admin123 grafana/grafana