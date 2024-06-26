resource "azurerm_kubernetes_cluster" "hadley_resource" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name                 = var.default_node_pool.name
    type                 = var.default_node_pool.type
    enable_auto_scaling  = var.default_node_pool.enable_auto_scaling
    node_count           = var.default_node_pool.node_count
    min_count            = var.default_node_pool.min_count
    max_count            = var.default_node_pool.max_count
    vm_size              = var.default_node_pool.vm_size
    os_disk_type         = var.default_node_pool.os_disk_type
    os_disk_size_gb      = var.default_node_pool.os_disk_size_gb
    os_sku               = var.default_node_pool.os_sku
    orchestrator_version = var.default_node_pool.orchestrator_version
    vnet_subnet_id       = var.default_node_pool.vnet_subnet_id
    zones                = var.default_node_pool.availability_zones

  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  role_based_access_control_enabled = true
  sku_tier = var.sku_tier
  kubernetes_version = var.kubernetes_version

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = file(var.ssh_key)
    }
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy 
    load_balancer_sku  = var.load_balancer_sku
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip    
  }

  

  tags = {
    for tag in var.tags:
    tag.key => tag.value
  }
}