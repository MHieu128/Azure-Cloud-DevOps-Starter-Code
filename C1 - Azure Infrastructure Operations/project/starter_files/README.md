# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction

For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started

1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies

1. Create an [Azure Account](https://portal.azure.com)
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

1. Login to Azure with command-line: `az login`
2. Create an Azure policy with CLI: `sh create_policy.sh`.
3. Run `az policy assignment list` to recheck the policy applied.
4. Create an image resource group `az group create --location eastus --name az-devops-rg`
5. Create a service principal `az ad sp create-for-rbac --role="Contributor" --name="PackerSP" --scopes /subscriptions/8dcdd40b-96b3-4cb1-8a5a-768e469afebe --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"`
6. Edit server.json with SP have been created as the last step with: client_id, client_secret, tenant_id
7. Create packer image follow `packer build server.json`
8. Edit the vars.tf
9. Run `terraform init`
10. Run `terraform plan -out solution.plan`
11. Run `terraform apply`

### Note

Remember destroy all Azure resources. Following the commnd below:
`terraform destroy`
`az image delete -g az-devops-rg -n my-packer-image`

### Output

The resources will be generated in Azure with informations are declared at files: policyRules.json, server.json, main.tf, variables.tf, solution.plan
