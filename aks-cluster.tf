resource "random_pet" "prefix" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${random_pet.prefix.id}-rg"
  location = "eastus"

  tags = {
    environment = "Demo"
  }
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${random_pet.prefix.id}-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"
  kubernetes_version  = "1.31.2"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_B4ms"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "Demo"
  }
}

# Kubernetes Provider Configuration
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.default.kube_config[0].host
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].cluster_ca_certificate)
  client_certificate     = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].client_key)
}

resource "kubernetes_namespace" "kindle" {
  metadata {
    name = "kindle"
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

# Helm Provider Configuration
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.default.kube_config[0].host
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].cluster_ca_certificate)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].client_key)
  }
}


# Install ArgoCD via Helm Chart
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace = kubernetes_namespace.kindle.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.8.21"  # Latest version of ArgoCD, or use the required version
  create_namespace = false

  values = [
    <<-EOF
    server:
      ingress:
        enabled: false  # Disable the internal ingress setup in ArgoCD
    EOF
  ]
}

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  namespace = kubernetes_namespace.kindle.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  create_namespace = false

  values = [
    <<-EOF
    controller:
      service:
        annotations:
          service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz
        externalTrafficPolicy: Local
    EOF
  ]
}


resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace = kubernetes_namespace.cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.14.3"
  create_namespace = false 

  values = [
    <<-EOF
    installCRDs: true
    extraArgs:
      - --dns01-recursive-nameservers=8.8.8.8:53,1.1.1.1:53
    EOF
  ]
}

resource "helm_release" "cert_manager_duckdns_webhook" {
  name       = "cert-manager-webhook-duckdns"
  namespace  = "cert-manager"
  chart      = "./deploy/cert-manager-webhook-duckdns"
  depends_on = [helm_release.cert_manager]

  values = [
    <<-EOF
    duckdns:
      token: "${var.duckdns_token}" 
    clusterIssuer:
      production:
        create: true
      staging:
        create: true
      email: "suraj.aims@gmail.com"
    logLevel: 2
    EOF
  ]
}
data "kubernetes_service" "nginx_ingress_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace.kindle.metadata[0].name
  }
}
