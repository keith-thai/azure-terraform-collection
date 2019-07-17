Azure Terraform

> Creating Service Principal, AKS and Application Gateway

## Components

- `Service Principal` - `Service Principal` Application required for AKS and Managed Identity
- `Resource Group` - To replace the resources
- `Virtual Network` - Containing two subnet: one for AKS and one for application gateway
- `Managed Identity` - Required for the application gateway ingress controller
- `Application Gateway` - Required for the application gateway ingress controller
- `AKS` - Main dish
- `Role Assignments` - Allow the in-cluster application to control application gateway with `Managed Identity`

## Usage

```sh
# Change some variables with your favourite editor
vim terraform.tfvars

# Terraform init
terraform init

# Terraform plan and apply
terraform plan
terraform apply

# Continue to setup the ingress controller
chrome https://github.com/Azure/application-gateway-kubernetes-ingress/blob/master/docs/setup/install-new.md#setting-up-application-gateway-ingress-controller-on-aks
```