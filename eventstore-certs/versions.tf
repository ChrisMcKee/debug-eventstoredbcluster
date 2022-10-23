
terraform {
  required_version = ">= 0.15"
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}
