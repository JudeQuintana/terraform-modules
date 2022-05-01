terraform {
  required_version = "~> 1"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.12"
      configuration_aliases = [aws.local, aws.peer]
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.3"
    }
  }
}
