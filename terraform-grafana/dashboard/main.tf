
provider "grafana" {
  url   = "http://localhost:3000/"
  auth = "glsa_CJQgErwQMJaImSXEgqiUC54ihsljN6xj_370c0b10"
}


resource "grafana_folder" "create_folder_on_grafana" {
  title = var.grafana_dashboard_folder_name
}

resource "grafana_dashboard" "deploy_dashboard" {
  for_each    = fileset("${var.dashboard_file_path}", "**")
  config_json = file("${var.dashboard_file_path}/${each.key}")
  folder      = grafana_folder.create_folder_on_grafana.id
}



# docker run -d --name=sample_grafana -p 3000:3000 -e GF_AUTH_BASIC_ENABLED=true -e GF_SECURITY_ADMIN_USER=admin -e GF_SECURITY_ADMIN_PASSWORD=admin123 grafana/grafana
