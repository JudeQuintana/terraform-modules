terraform {
  required_version = "~>1.2"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~>4.20"
      configuration_aliases = [aws.local, aws.peer]
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.3"
    }
  }
}
