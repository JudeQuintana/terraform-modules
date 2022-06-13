terraform {
  required_version = "~> 1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.18"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.3"
    }
  }
}
