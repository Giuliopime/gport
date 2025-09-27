terraform {
  required_version = ">= 1.5.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.51.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.10.1"
    }
  }
}
