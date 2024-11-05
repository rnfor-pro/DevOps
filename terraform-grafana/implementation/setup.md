# Creating and Managing Grafana Dashboards Using Terraform

This document provides a guide to using Terraform to create and manage Grafana dashboards. By implementing Infrastructure as Code (IaC) with Terraform, we can standardize our Grafana dashboard deployments, ensure consistency, and simplify changes. This document covers prerequisites, setup, and deployment steps to help team members quickly and effectively work with Grafana dashboards in a controlled and reproducible way.

---

## Prerequisites

### For Windows Users

1. **Install Terraform**:
   - Download Terraform from [HashiCorp's official site](https://www.terraform.io/downloads.html).
   - Extract the downloaded `.zip` file and move the `terraform.exe` file to a directory in your PATH (e.g., `C:\Program Files\Terraform`).
   - Confirm installation by running `terraform -version` in Command Prompt or PowerShell.

2. **Install Git**:
   - Install Git for Windows from [git-scm.com](https://git-scm.com/download/win).

3. **Install a Code Editor**:
   - Recommended: [Visual Studio Code](https://code.visualstudio.com/).

4. **Configure Environment Variables**:
   - Ensure the directory containing `terraform.exe` is in your PATH by editing environment variables.

5. **Install Grafana CLI (if needed)**:
   - If you need to manage plugins, download and install [Grafana CLI](https://grafana.com/docs/grafana/latest/setup-grafana/installation/).

### For Mac Users

1. **Install Homebrew** (if not already installed):
   - Open Terminal and run:
     ```bash
     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
     ```

2. **Install Terraform**:
   - Install via Homebrew:
     ```bash
     brew tap hashicorp/tap
     brew install hashicorp/tap/terraform
     ```
   - Verify installation:
     ```bash
     terraform -version
     ```

3. **Install Git**:
   - Install via Homebrew:
     ```bash
     brew install git
     ```

4. **Install a Code Editor**:
   - Recommended: [Visual Studio Code](https://code.visualstudio.com/).

5. **Install Grafana CLI (if needed)**:
   - Install Grafana CLI via Homebrew:
     ```bash
     brew install grafana
     ```

---

## Implementation Steps

### Step 1: Set Up Your Grafana API Key

1. **Log in to Grafana**.
2. Navigate to **Configuration > API Keys**.
3. Create a new API key with sufficient permissions (Admin or Editor) and copy the key for later use.

### Step 2: Clone or Create Your Terraform Project Directory

1. Open Terminal (Mac) or Command Prompt (Windows).
2. Navigate to the directory where you want to set up your Terraform configuration, or clone an existing repo if available:
   ```bash
   git clone <repository-url>

3. Create a new folder for storing your Terraform files if you’re starting from scratch:

```bash
mkdir grafana-terraform && cd grafana-terraform
```
### Step 3: Create the Terraform Configuration Files

1. Provider Configuration:

- Create a file named provider.tf to define the Grafana provider:
```hcl
provider "grafana" {
  url  = var.grafana_endpoint
  auth = var.grafana_service_account_api_key
}

terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "3.12.0"
    }
  }
}

```
