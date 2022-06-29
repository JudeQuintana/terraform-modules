terraform {
  required_version = "~>1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.20"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1.3"
    }
  }
  # needed for utilizing optional() and defaults() until they're GA
  experiments = [module_variable_optional_attrs]
}
