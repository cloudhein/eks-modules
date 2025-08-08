terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}

provider "aws" {
  profile = "terraform-cloud-user"
  region  = "ap-southeast-1"
}