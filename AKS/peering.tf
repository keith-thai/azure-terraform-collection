# # There might be a few peerings exist, so we don't want to put it in tfvars

# locals {
#   peering_resource_group_name  = "WHATEVER-RG"
#   peering_virtual_network_name = "WHATEVER-VN"
# }

# data "azurerm_virtual_network" "destination-vnet" {
#   resource_group_name = "${local.peering_resource_group_name}"
#   name                = "${local.peering_virtual_network_name}"
# }

# resource "azurerm_virtual_network_peering" "peering-out" {
#   name                         = "peering-to-${local.peering_virtual_network_name}"
#   resource_group_name          = "${azurerm_resource_group.rg.name}"
#   virtual_network_name         = "${azurerm_virtual_network.vnet.name}"
#   remote_virtual_network_id    = "${data.azurerm_virtual_network.destination-vnet.id}"
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = false
# }

# resource "azurerm_virtual_network_peering" "peering-in" {
#   name                      = "peering-to-${local.virtual_network_name}"
#   resource_group_name       = "${local.peering_resource_group_name}"
#   virtual_network_name      = "${data.azurerm_virtual_network.destination-vnet.name}"
#   remote_virtual_network_id = "${azurerm_virtual_network.vnet.id}"
# }
