resource_group_name = "AKS-RG"

location = "eastasia"

####

app_gateway_sku = "Standard_Small" # Note: East asia don't have "Standard_V2" sku, and the public ip with "Standard" sku should be in "Dynamic" type

app_gateway_tier = "Standard"

app_gateway_capacity = 1

aks_cluster_name = "aks-dev"

virtual_network_address_prefix = "15.0.0.0/8"

aks_subnet_address_prefix = "15.0.0.0/16"

aks_agent_count = 1

aks_agent_vm_size = "Standard_B2s" # Lowest price VM you are allowed to use booting up an AKS is `Standard_B2s`

kubernetes_version = "1.13.5"

aks_enable_rbac = true

####

acr_resource_group_name = "ACR-RG"

acr_name = "youracrname"

aks_service_principal_client_secret_path = "/path/to/the/aks_sp_client_secret"

public_ssh_key_path = "/path/to/the/public_key"

####

# Modify values in:
# - backend.tf    => For terraform remote state storing
# - peering.tf    => Maybe you will need a peering?
