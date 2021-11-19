terraform {
  required_version = "~> 1.0.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.53.0"
    }
  }
  # needed for utilizing optional() and defaults() until they're GA
  experiments = [module_variable_optional_attrs]
}
