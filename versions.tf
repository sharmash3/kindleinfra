terraform {
  required_version = ">= 1.5.7"  # To ensure you're using Terraform version 1.5.7 or higher

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.26.0"  # Specify the version you're using for the azurerm provider
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.36.0"  # Specify the version you're using for the kubernetes provider
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.17.0"  # Specify the version you're using for the helm provider
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.1"  # Specify the version you're using for the random provider
    }
  }
}