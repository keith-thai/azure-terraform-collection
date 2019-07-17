output "resource_group_name" {
    value = "${var.resource_group_name}"
}

output "app_gateway_name" {
    value = "${local.app_gateway_name}"
}

output "app_gateway_id" {
    value = "${azurerm_application_gateway.app-gateway.id}"
}

output "identity_id" {
    value = "${azurerm_user_assigned_identity.identity.id}"
}


output "identity_client_id" {
    value = "${azurerm_user_assigned_identity.identity.client_id}"
}

output "cluster_host" {
    value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.host}"
}
