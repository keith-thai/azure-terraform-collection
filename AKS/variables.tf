variable "resource_group_name" {
  description = "Name of the resource group, it will be also the aks cluster name"
}

variable "aks_cluster_name" {
  description = "Name of the resource group, it will be also the aks cluster name"
}

variable "location" {
  description = "Location of the cluster."
}

variable "aks_service_principal_client_secret_path" {
  description = "Secret file of the service principal. Used by AKS to manage Azure."
}

variable "virtual_network_address_prefix" {
  description = "Containers DNS server IP address."
}

variable "aks_subnet_address_prefix" {
  description = "Containers DNS server IP address."
}

variable "aks_agent_os_disk_size" {
  description = "Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize."
  default     = 30
}

variable "aks_agent_count" {
  description = "The number of agent nodes for the cluster."
  default     = 1
}

variable "aks_agent_vm_size" {
  description = "The size of the Virtual Machine."
  default     = "Standard_B2s" # Cheapest you can use is Standard_B2s
}

variable "kubernetes_version" {
  description = "The version of Kubernetes."
  default     = "1.13.5"
}

variable "aks_service_cidr" {
  description = "A CIDR notation IP range from which to assign service cluster IPs."
  default     = "10.0.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "Containers DNS server IP address."
  default     = "10.0.0.10"
}

variable "aks_docker_bridge_cidr" {
  description = "A CIDR notation IP for Docker bridge."
  default     = "172.17.0.1/16"
}

variable "aks_enable_rbac" {
  description = "Enable RBAC on the AKS cluster. Defaults to false."
  default     = true
}

variable "acr_resource_group_name" {
  description = "Azure ACR resource group name"
}

variable "acr_name" {
  description = "Azure ACR name"
}

variable "vm_user_name" {
  description = "User name for the VM"
  default     = "ubuntu"
}

variable "public_ssh_key_path" {
  description = "Public key path for SSH."
  default     = "~/.ssh/id_rsa.pub"
}

variable "tags" {
  type = "map"

  default = {
    source = "terraform"
  }
}
