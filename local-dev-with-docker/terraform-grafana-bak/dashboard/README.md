# Terraform
Terraform is an infrastructure as code tool that lets you build, change, and version cloud and on-prem resources safely and efficiently.

Initialize the Terraform working directory, download and install provider's plugins.
```bash
terraform init
```
Ensure all Terraform configuration files are properly formatted.
```bash
terraform fmt
```
Validate the code by Checking for syntax errors or misconfigurations.
```bash
terraform validate
```
Generate an execution plan to see the resources that will be created, updated, or destroyed.
```bash
terraform plan
```
Apply the changes to provision the infrastructure.
```bash
terraform apply
```

If run into an error such as Call to function "file" failed: contents of "dashboards//.DS_Store" are not valid UTF-8; use the filebase64 function to obtain the Base64 encoded contents or the other file functions (e.g. filemd5, filesha256) to obtain file hashing results instead.
Run the command below.
```bash
find . -name ".DS_Store" -delete
```

- Importing pre-existing dashbaords
  -  get the UID of a Grafana dashboard you want to import into Terraform
```bash
curl -X GET -H "Authorization: Bearer <API_KEY>" http://<your-grafana-url>/api/search

curl -X GET -H "Authorization: Bearer glsa_Av5iK7tGdaCjQxweTyTYO7cxGmB3liVG_3c5b2d7d" http://localhost:3000/api/search | jq
```

- To extract only the dashboard name, data source, and UID from the JSON response
```bash
curl -X GET -H "Authorization: Bearer <API_KEY>" http://<your-grafana-url>/api/search | jq '.[] | {name: .title, uid: .uid}'

curl -X GET -H "Authorization: Bearer glsa_Av5iK7tGdaCjQxweTyTYO7cxGmB3liVG_3c5b2d7d" http://localhost:3000/api/search | jq '.[] | {name: .title, uid: .uid}'

```

- The response will include details for each dashboard, including the UID. Example response
```bash
[
  {
    "uid": "ae54tmzfw7hfkb",
    "title": "Dashboard Title",
    "uri": "db/dashboard-title",
    "url": "/d/ae54tmzfw7hfkb/dashboard-title",
    "type": "dash-db"
  }
]
``` 

- Define the Resource in Your Terraform Configuration
```bash
resource "grafana_dashboard" "name" {
  config_json = "{}" # Placeholder, this will be overwritten after import
}

```

- Run the Import Command
```bash
terraform import grafana_dashboard.name ae54tmzfw7hfkb
```
- Verify the Import
```bash
terraform show
```
- Update the Configuration Or by manually exporting the dashboard JSON from Grafana's UI.
```bash
grafana_dashboard_export --uid ae54tmzfw7hfkb
```
- Reapply Configuration
```bash
terraform plan
terraform apply
```





