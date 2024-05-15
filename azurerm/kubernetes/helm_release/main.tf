



data "terraform_remote_state" "aks" {
  backend = "azurerm"
  
  config = {
    subscription_id      = var.cluster_subscription_id
    resource_group_name  = var.cluster_resource_group_name
    storage_account_name = var.cluster_storage_account_name
    container_name       = "terraform-state"
    key                  = var.cluster_storage_key
    use_azuread_auth     = false
  }
}

data "azurerm_kubernetes_cluster" "cluster" {
  name                = var.name
  resource_group_name = var.resource_group_name
}



provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.cluster.kube_config[0].host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
  
    # host                   = data.terraform_remote_state.aks.endpoint
    # cluster_ca_certificate = base64decode(data.terraform_remote_state.aks.certificate_authority.0.data)
    # exec {
    #   api_version = "client.authentication.k8s.io/v1beta1"
    #   args        = ["aks", "get-credentials", "--name", data.azurerm_kubernetes_cluster.cluster.name, "-g", data.terraform_remote_state.aks.resource_group_name]
    #   command     = "az"
  
    # }
  }
}



resource "helm_release" "hadley_resource" {
  name       = var.helm_name
  repository = var.helm_repository
  chart      = var.helm_chart

  values = [
    file(var.helm_file)
  ]
}


data "kubernetes_service" "hadley_resource" {
  depends_on = [helm_release.hadley_resource]
  metadata {
    name = "nginx"
  }
}
