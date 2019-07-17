provider "azurerm" {
    version = ">=1.30.0"
}

provider "azuread" {
    version = ">=0.4.0"
}

#################################################################

# Locals block for hardcoded names. 
locals {
    ad_application_name            = "${var.aks_cluster_name}-ad-app"
    ad_application_uri             = "https://${var.aks_cluster_name}"
    virtual_network_name           = "${var.aks_cluster_name}-vnet"
    backend_address_pool_name      = "${var.aks_cluster_name}-vnet-be-ap"
    frontend_port_name             = "${var.aks_cluster_name}-vnet-fe-port"
    frontend_ip_configuration_name = "${var.aks_cluster_name}-vnet-fe-ip"
    http_setting_name              = "${var.aks_cluster_name}-vnet-be-htst"
    listener_name                  = "${var.aks_cluster_name}-vnet-http-lstn"
    request_routing_rule_name      = "${var.aks_cluster_name}-vnet-rq-rt"
    managed-identity               = "${var.aks_cluster_name}-identity"
    aks_subnet_name                = "${var.aks_cluster_name}-kube-subnet"
    app_gateway_subnet_name        = "${var.aks_cluster_name}-ag-subnet"
    public_ip_name                 = "${var.aks_cluster_name}-public-ip"
    app_gateway_name               = "${var.aks_cluster_name}-ag"
    aks_name                       = "${var.aks_cluster_name}"
    aks_dns_prefix                 = "${var.aks_cluster_name}"
}

#################################################################

data "azurerm_subscription" "subscription" {}

data "azurerm_container_registry" "acr" {
    resource_group_name  = "${var.acr_resource_group_name}"
    name                 = "${var.acr_name}"
}

#################################################################

# Active directory
resource "azuread_application" "ad-app" {
    name                       = "${local.ad_application_name}"
    homepage                   = "${local.ad_application_uri}"
    identifier_uris            = ["${local.ad_application_uri}"]
    reply_urls                 = []
    available_to_other_tenants = false
    oauth2_allow_implicit_flow = false
    type                       = "webapp/api"
}

resource "azuread_service_principal" "ad-sp" {
    application_id = "${azuread_application.ad-app.application_id}"
}

resource "azuread_service_principal_password" "ad-sp-pw" {
    service_principal_id = "${azuread_service_principal.ad-sp.id}"
    value                = "${file(var.aks_service_principal_client_secret_path)}"
    end_date_relative    = "17520h"
}

# Role assignments for service principal
resource "azurerm_role_assignment" "ad-sp-ra" {
    scope                = "${data.azurerm_subscription.subscription.id}"
    role_definition_name = "Contributor"
    principal_id         = "${azuread_service_principal.ad-sp.id}"
}

#################################################################

# Resources
resource "azurerm_resource_group" "rg" {
    name     = "${var.resource_group_name}"
    location = "${var.location}"

    tags = "${var.tags}"
}

# User Assigned Idntities 
resource "azurerm_user_assigned_identity" "identity" {
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location            = "${azurerm_resource_group.rg.location}"

    name = "${local.managed-identity}"
    tags = "${var.tags}"

    depends_on = ["azurerm_resource_group.rg"]
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
    name                = "${local.virtual_network_name}"
    location            = "${azurerm_resource_group.rg.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    address_space       = ["${var.virtual_network_address_prefix}"]

    tags = "${var.tags}"
}

# Subnets
resource "azurerm_subnet" "kube-subnet" {
    name                 = "${local.aks_subnet_name}"
    resource_group_name  = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${local.virtual_network_name}"
    address_prefix = "${var.aks_subnet_address_prefix}"

    depends_on = ["azurerm_virtual_network.vnet"]
}

resource "azurerm_subnet" "ag-subnet" {
    name                 = "${local.app_gateway_subnet_name}"
    resource_group_name  = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${local.virtual_network_name}"
    address_prefix = "${var.app_gateway_subnet_address_prefix}"
    
    depends_on = ["azurerm_virtual_network.vnet"]
}

# Public IP 
resource "azurerm_public_ip" "public-ip" {
    name                         = "${local.public_ip_name}"
    location                     = "${azurerm_resource_group.rg.location}"
    resource_group_name          = "${azurerm_resource_group.rg.name}"
    sku                          = "Basic"
    allocation_method            = "Dynamic"

    tags = "${var.tags}"
}

resource "azurerm_application_gateway" "app-gateway" {
    name                = "${local.app_gateway_name}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location            = "${azurerm_resource_group.rg.location}"

    sku {
        name     = "${var.app_gateway_sku}"
        tier     = "${var.app_gateway_tier}"
        capacity = "${var.app_gateway_capacity}"
    }

    gateway_ip_configuration {
        name      = "gateway-ip-configuration"
        subnet_id = "${azurerm_subnet.ag-subnet.id}"
    }

    frontend_port {
        name = "${local.frontend_port_name}"
        port = 80
    }

    frontend_port {
        name = "httpsPort"
        port = 443
    }

    frontend_ip_configuration {
        name                 = "${local.frontend_ip_configuration_name}"
        public_ip_address_id = "${azurerm_public_ip.public-ip.id}"
    }

    backend_address_pool {
        name = "${local.backend_address_pool_name}"
    }

    backend_http_settings {
        name                  = "${local.http_setting_name}"
        cookie_based_affinity = "Disabled"
        port                  = 80
        protocol              = "Http"
        request_timeout       = 1
    }

    http_listener {
        name                           = "${local.listener_name}"
        frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}"
        frontend_port_name             = "${local.frontend_port_name}"
        protocol                       = "Http"
    }

    request_routing_rule {
        name                       = "${local.request_routing_rule_name}"
        rule_type                  = "Basic"
        http_listener_name         = "${local.listener_name}"
        backend_address_pool_name  = "${local.backend_address_pool_name}"
        backend_http_settings_name = "${local.http_setting_name}"
    }

    tags = "${var.tags}"

    lifecycle {
        ignore_changes = ["tags", "backend_address_pool", "backend_http_settings", "frontend_port", "http_listener", "probe", "request_routing_rule"] # These will be managed by app gateway ingress controller later
    }

    depends_on = ["azurerm_virtual_network.vnet", "azurerm_public_ip.public-ip"]
}

# Role assignments for vnet and app gateway
resource "azurerm_role_assignment" "ra-allow-sp-manage-kube-subnet" {
    scope                = "${azurerm_subnet.kube-subnet.id}"
    role_definition_name = "Network Contributor"
    principal_id         = "${azuread_service_principal.ad-sp.id}"
    depends_on = ["azurerm_virtual_network.vnet"]
}

resource "azurerm_role_assignment" "ra-allow-sp-manage-identity" {
    scope                = "${azurerm_user_assigned_identity.identity.id}"
    role_definition_name = "Managed Identity Operator"
    principal_id         = "${azuread_service_principal.ad-sp.id}"
    depends_on           = ["azurerm_user_assigned_identity.identity"]
}

resource "azurerm_role_assignment" "ra-allow-identity-manage-app-gateway" {
    scope                = "${azurerm_application_gateway.app-gateway.id}"
    role_definition_name = "Contributor"
    principal_id         = "${azurerm_user_assigned_identity.identity.principal_id}"
    depends_on           = ["azurerm_user_assigned_identity.identity", "azurerm_application_gateway.app-gateway"]
}

resource "azurerm_role_assignment" "ra-allow-identity-read-resource" {
    scope                = "${azurerm_resource_group.rg.id}"
    role_definition_name = "Reader"
    principal_id         = "${azurerm_user_assigned_identity.identity.principal_id}"
    depends_on           = ["azurerm_user_assigned_identity.identity", "azurerm_application_gateway.app-gateway"]
}

resource "azurerm_role_assignment" "ra-allow-sp-acr-pull" {
    scope                = "${data.azurerm_container_registry.acr.id}"
    role_definition_name = "AcrPull"
    principal_id         = "${azuread_service_principal.ad-sp.id}"
}

# The cluster
resource "azurerm_kubernetes_cluster" "k8s" {
    name       = "${local.aks_name}"
    location   = "${azurerm_resource_group.rg.location}"
    dns_prefix = "${local.aks_dns_prefix}"

    kubernetes_version  = "${var.kubernetes_version}"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    linux_profile {
        admin_username = "${var.vm_user_name}"

        ssh_key {
            key_data = "${file(var.public_ssh_key_path)}"
        }
    }

    addon_profile {
        http_application_routing {
            enabled = false
        }
    }

    agent_pool_profile {
        name            = "nodes"
        count           = "${var.aks_agent_count}"
        vm_size         = "${var.aks_agent_vm_size}"
        os_type         = "Linux"
        os_disk_size_gb = "${var.aks_agent_os_disk_size}"
        vnet_subnet_id  = "${azurerm_subnet.kube-subnet.id}"
    }

    network_profile {
        network_plugin     = "azure"
        dns_service_ip     = "${var.aks_dns_service_ip}"
        docker_bridge_cidr = "${var.aks_docker_bridge_cidr}"
        service_cidr       = "${var.aks_service_cidr}"
    }

    role_based_access_control {
        enabled = "${var.aks_enable_rbac}"
    }

    service_principal {
        client_id     = "${azuread_service_principal.ad-sp.application_id}"
        client_secret = "${file(var.aks_service_principal_client_secret_path)}"
    }

    depends_on = ["azurerm_virtual_network.vnet", "azurerm_application_gateway.app-gateway"]
    tags       = "${var.tags}"
}

# Check if the provider is supporting your region or not

# resource "azurerm_devspace_controller" "dev-space" {
#     name                = "${local.aks_dev_space_name}"
#     location            = "${azurerm_resource_group.rg.location}"
#     resource_group_name = "${azurerm_resource_group.rg.name}"

#     sku {
#         name = "S1"
#         tier = "Standard"
#     }

#     host_suffix                              = "${local.aks_dev_space_name_host_suffix}"
#     target_container_host_resource_id        = "${azurerm_kubernetes_cluster.k8s.id}"
#     target_container_host_credentials_base64 = "${base64encode(azurerm_kubernetes_cluster.k8s.kube_config_raw)}"

#     tags                = "${var.tags}"
# }
