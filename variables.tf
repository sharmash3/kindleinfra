variable "appId" {
  description = "Azure Kubernetes Service Cluster service principal"
  type = string
}

variable "password" {
  description = "Azure Kubernetes Service Cluster password"
  type = string
}

variable "duckdns_token" {
  type = string
  sensitive = true
}