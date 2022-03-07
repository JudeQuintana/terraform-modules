# Blog Post
Please see the [Tiered VPC in Terraform
0.13](https://jq1.io/posts/tiered_vpc) blog post for more
details.

## This module is deprecataed
Please use [Tiered VPC-NG](https://github.com/JudeQuintana/terraform-modules/tree/master/networking/tiered_vpc_ng) instead!

## Description
Create VPC tiers.

Requires a minimum of at least one public subnet.

Private subnets can be nulled out.

Can add and remove subnets and AZs at any time.

Routing and structured naming for resource tagging is automatic.

NAT Gateways (with EIP) are created per AZ for private subnets.

All public and private subnets will have randomly generated name to differentiate each subnet.

## Usage
```
terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# default provider
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "usw2"
}

variable "env_prefix" {
  default = "test"
}

variable "region_az_labels" {
  type = map(string)

  default = {
    us-east-1  = "use1"
    us-east-1a = "use1a"
    us-east-1b = "use1b"
    us-east-2c = "use1c"
    us-west-2  = "usw2"
    us-west-2a = "usw2a"
    us-west-2b = "usw2b"
    us-west-2c = "usw2c"
  }
}

locals {
  tiers = [
    {
      azs = {
        a = {
          private = ["10.0.8.0/24", "10.0.9.0/24"]
          public  = ["10.0.0.0/24", "10.0.1.0/24"]
        },
        b = {
          private = ["10.0.11.0/24", "10.0.12.0/24"]
          public  = ["10.0.3.0/24", "10.0.4.0/24"]
        },
      }
      name    = "app"
      network = "10.0.0.0/20"
    },
    {
      azs = {
        a = {
          private = ["10.0.16.0/24", "10.0.17.0/24"]
          public  = ["10.0.28.0/28"] # 10.0.28.0/24 chopped up into /28
        },
        b = {
          private = ["10.0.20.0/24", "10.0.21.0/24"]
          public  = ["10.0.28.16/28"] # 10.0.28.0/24 chopped up into /28
        },
      }
      name    = "db"
      network = "10.0.16.0/20"
    },
    {
      azs = {
        a = {
          private = ["10.47.11.0/24", "10.47.12.0/24"]
          public  = ["10.47.0.0/28", "10.47.0.16/28"] # 10.47.0.0/24 chopped up into /28
        },
        c = {
          private = null
          public  = ["10.47.6.0/24", "10.47.7.0/24"]
        },
      }
      name    = "general"
      network = "10.47.0.0/20"
    }
  ]
}

module "usw2_vpcs" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/tiered_vpc?ref=v1.1.1"

  for_each = { for t in local.tiers : t.name => t }

  providers = {
    aws = aws.usw2
  }

  tier             = each.value
  env_prefix       = var.env_prefix
  region_az_labels = var.region_az_labels
}

```
