# Ratecard Platform Infrastructure (Platform Team Repo)

Enterprise Infrastructure-as-Code (Terraform) repository for provisioning and managing cloud resources for the **Ratecard Lakehouse Platform**.

## Architecture & Modules

```text
ratecard_platform_infra/
├── .github/workflows/
│   ├── terraform_plan.yml      # CI: Triggered on Pull Request to validate and plan
│   └── terraform_apply.yml     # CD: Triggered on merge to main to apply changes
│
├── modules/
│   ├── storage/                # ADLS Gen2 + HNS + Medallion containers (bronze/silver/gold)
│   ├── key_vault/              # Azure Key Vault with RBAC Authorization
│   ├── data_factory/           # ADF v2 with System-Assigned Managed Identity & Git Integration
│   └── databricks/             # Databricks Premium Workspace
│
└── environments/
    ├── dev/                    # Development Environment Configuration
    └── prod/                   # Production Environment Configuration
```

## GitHub Actions CI/CD Secrets

To enable automated provisioning via GitHub Actions, add these repository secrets:

- `ARM_CLIENT_ID`: Azure Service Principal Application ID (`sp-platform-infra-dev`)
- `ARM_CLIENT_SECRET`: Azure Service Principal Secret Value
- `ARM_TENANT_ID`: Azure Directory (Tenant) ID
- `ARM_SUBSCRIPTION_ID`: Azure Subscription ID

## Local Execution (Platform Admin Only)

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

