output "resource_group_name" {
  value = azurerm_resource_group.default.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.default.name
}

# output "host" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.host
# }

# output "client_key" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.client_key
# }

# output "client_certificate" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.client_certificate
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.default.kube_config_raw
# }

# output "cluster_username" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.username
# }

# output "cluster_password" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.password
# }

output "nginx_ingress_load_balancer_ip" {
  description = "External IP of the ingress-nginx LoadBalancer service"
  value       = data.kubernetes_service.nginx_ingress_controller.status[0].load_balancer[0].ingress[0].ip
}
