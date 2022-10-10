# Azure Communication Service Terraform provisioning

This repo contains Terraform code to instantiate ACS architecture. Please have a look at this [draw.io file](/ACS_Architecture.drawio) for a visual reference.

Code is based on [Terraform](https://www.terraform.io/).

## How to use

Before starting, modify [terraform.tfvars](/terraform.tfvars) file to match your environment.
In particular, you can refer to [variables.tf](/variables.tf) to view all possible values for variables to insert here.

Things to be especially aware of:

- `acs_name`, `sa_name`, `kv_name`, `eventhub_name` must **ALL** be globally unique
- you can choose to use an existing resource group or create a new one
- you can choose to use an existing key vault or create a new one
- if you use an existing KeyVault, use `byok_name` to specify the name of the existing BYOK key to use (for dead letter storage encryption)
- if you use an existing KeyVault, also an existing Managed Identity must be used (see `mi_name` and `create_mi` variables), and an access policy must be already present for that Managed Identity to be able to access keys in the KeyVault
- you can define which objects must send logs and metrics to log-analytics. By default, metrics and logs are enabled on all objects. You can tweak each object by setting the corresponding variable to `false`
- change EventHub variables (such as `eventhub_capacity`, `eventhub_zone_redundant` and `eventhub_message_retention`, etc.) accordingly to your needs
- key vault and managed identity can have each their own existing resource group (for instance, if you pre-created them). Please set all variables accordingly, even if you let Terraform manage creation of everything (that is, it's better to **ALWAYS EXPLICITY SET** `rg_name`, `kv_rg_name` and `mi_rg_name` variables in your [terraform.tfvars](/terraform.tfvars) file)

## Terraform state

In this project, `terraform.tfstate` is not committed to the repo. This is because it contains sensitive information (such as secrets) and it is not recommended to store it in a public repo.

What should you do?

On Azure, the best thing to do is to use an existing storage account to store the state. You can use the same storage account used for the rest of the resources. Process is well-explained [here](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli).

Please use commented-out lines in [main.tf](/main.tf) to enable this, by changing them to suit your needs.

## How to instantiate

To instantiate architecture, run the following commands:

```bash
terraform init
terraform plan -var-file=terraform.tfvars -out plan.out
terraform apply plan.out
```
