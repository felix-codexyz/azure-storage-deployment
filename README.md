# azure-storage-deployment
Deploy an Azure Storage Account using Terraform via Terraform Cloud (CLI-Driven Workflow), triggered by GitHub Actions. A region-restriction policy must block deployments not in `East US` (for testing Azure Policy-as-Code).

# 📁 Repository: azure-storage-deployment.

## ✅ Objective
Deploy an Azure Storage Account using Terraform via Terraform Cloud (CLI-Driven Workflow), triggered by GitHub Actions. A region-restriction policy must block deployments not in `East US` (for testing Azure Policy as Code).

---

## 📦 Repository Structure
```bash
azure-storage-deployment/
├── .github/
│   └── workflows/
│       └── terraform.yml       # GitHub Actions CI/CD Workflow file (Triggers Plan and Apply)
├── modules/
│   └── storage_account/        # Reusable Terraform module to deploy Azure Storage Account
│       ├── main.tf             # Main module logic
│       ├── variables.tf        # Module input variables
│       └── outputs.tf          # Output values
├── main.tf                     # Root Terraform config - calls storage_account module
├── variables.tf                # Root input variables
├── versions.tf                 # Terraform and provider version config
├── terraform.tfvars            # Variable values (except secrets)
└── README.md                   # Project documentation
```

---

## 🧱 1. Create GitHub Repo & Push Code
```bash
# Step 1: Create repo on GitHub (name: azure-storage-deployment)
# ✅ Check the "Initialize with README" and ".gitignore -> Terraform"

# Step 2: Clone the repo locally
$ git clone https://github.com/<your-username>/azure-storage-deployment.git
$ cd azure-storage-deployment

# Step 3: Create folder structure
$ mkdir -p .github/workflows
$ mkdir -p modules/storage_account

# Step 4: Add all Terraform and GitHub Actions files (see below)

# Step 5: Push code
$ git add .
$ git commit -m "Initial commit"
$ git push origin main
```

---

## 🔐 2. Create Azure Service Principal for Terraform Auth
```bash
# Login to Azure
az login

# Get subscription ID
az account show --query "id" -o tsv

# Create Service Principal
az ad sp create-for-rbac --name "terraform-sp" \
  --role="Contributor" \
  --scopes="/subscriptions/<your-subscription-id>"

# Output will include:
# appId = ARM_CLIENT_ID
# password = ARM_CLIENT_SECRET
# tenant = ARM_TENANT_ID
```

---

## ☁️ 3. Configure Terraform Cloud Workspace
1. Go to [Terraform Cloud](https://app.terraform.io)
2. Create a workspace named: `azure-storage-workspace`
3. Select **CLI-Driven Workflow** (NOT Version Control)
4. Link to your Terraform Cloud **Organization**: `felfun-spz-technologies-azure-platform`
5. Under **Variables Tab**:

### Environment Variables (Sensitive)
| Key                    | Value                       |
|------------------------|-----------------------------|
| `ARM_CLIENT_ID`        | From SP output              |
| `ARM_CLIENT_SECRET`    | From SP output              |
| `ARM_SUBSCRIPTION_ID`  | Azure subscription ID       |
| `ARM_TENANT_ID`        | From SP output              |

### Terraform Variables
| Key                        | Value                  |
|----------------------------|------------------------|
| `TF_VAR_storage_account_name` | demostoragespz123456  |
| `TF_VAR_location`              | australiaeast         |

✅ **Note:** Using `TF_VAR_` prefix ensures GitHub Actions injects them correctly.

---

## 🧾 4. GitHub Actions Workflow - `.github/workflows/terraform.yml`
```yaml
ame: Deploy Azure Storage

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  terraform:
    name: Terraform Plan & Apply
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.7.5
          cli_config_credentials_token: ${{ secrets.TFC_API_TOKEN }}

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan

      - name: Terraform Apply (only on main)
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -auto-approve

    env:
      ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
      TF_VAR_storage_account_name: ${{ vars.TF_VAR_storage_account_name }}
      TF_VAR_location: ${{ vars.TF_VAR_location }}
```

---

## ☁️ 5. Terraform Files

### 🔹 `versions.tf`
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.65.0"
    }
  }

  cloud {
    organization = "felfun-spz-technologies-azure-platform"
    workspaces {
      name = "azure-storage-workspace"
    }
  }
}

provider "azurerm" {
  features {}
}
```

---

### 🔹 `main.tf` (Root Level)
```hcl
module "storage" {
  source                  = "./modules/storage_account"
  storage_account_name    = var.storage_account_name
  location                = var.location
}
```

---

### 🔹 `variables.tf` (Root Level)
```hcl
variable "storage_account_name" {
  type = string
}

variable "location" {
  type = string
  default = "australiaeast"
}
```

---

### 🔹 `terraform.tfvars`
```hcl
storage_account_name = "demostoragespz123456"
location             = "australiaeast"
```

---

## 🧱 Module: `modules/storage_account/`

### 🔹 `main.tf`
```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-demo-storage"
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

### 🔹 `variables.tf`
```hcl
variable "storage_account_name" {
  type = string
}

variable "location" {
  type = string
}
```

### 🔹 `outputs.tf`
```hcl
output "storage_account_id" {
  value = azurerm_storage_account.storage.id
}
```

---

## ✅ How It Works
- Push to **`main`** branch → triggers `terraform plan` and `terraform apply`
- Pull request to **`main`** → triggers `terraform plan` only
- Policy in Azure should block the apply if region is not `East US`

---

## 🧪 Final Test
1. Make a branch like `feature/test-storage`
2. Change `location` in `terraform.tfvars` to `eastus` → PR → should pass and deploy
3. Change `location` to `australiaeast` → PR → should fail apply due to region restriction

---
END