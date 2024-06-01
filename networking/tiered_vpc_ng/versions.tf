terraform {
  required_version = ">=1.4" # using anytrue()
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.31"
    }
  }
}
