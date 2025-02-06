To ensure that multiple people can deploy this code in the same environment without conflicts, I have introduced a unique identifier for each deployment. This is achieved by using a combination of a unique variable (e.g., `deployment_id`) and a `terraform.tfvars` file. This way, each deployment will have a unique identifier appended to the resource names, preventing naming conflicts.

### Step 1: Modify the Terraform Code

1. **Add a `deployment_id` variable**:
   This variable will be used to uniquely identify each deployment.

2. **Append the `deployment_id` to resource names**:
   Modify the resource names to include the `deployment_id` to ensure uniqueness.

### Step 2: Create a `terraform.tfvars` File

Create a `terraform.tfvars` file to provide the `deployment_id` value. Each user should have a unique `deployment_id`:

```hcl
deployment_id = "user1-unique-id"
```

### Step 3: Deploy the Code

Create a `terraform.tfvars` file with a unique `deployment_id`. This ensures that resource names are unique across deployments, preventing conflicts.

### Example:

- User 1's `terraform.tfvars`:
  ```hcl
  deployment_id = "user1-unique-id"
  ```

- User 2's `terraform.tfvars`:
  ```hcl
  deployment_id = "user2-unique-id"
  ```

This approach ensures that each deployment is uniquely identified, and resources created by different users do not conflict with each other. 

```hcl
terraform init
terraform plan
terraform apply
```

```hcl
az aks get-credentials --resource-group core-rg --name <clusterName>
```
```bash
kubectl get nodes
```

