terraform-grafana
├── dashboards
│   ├── my_containers_dashboard.json        
│   ├── mydashboard1.json     
│   └── mydashboard2                   
├── README.md                
├── main.tf 
├── vars.tf                
├── providers.tf
├── outputs.tf 
├── terraform.tfvars


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
