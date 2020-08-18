# Overview

This is a [Dynamic VPC Module](http://localhost) that builds a redundant network
architecture in AWS based on structured input using `for_each` and `for`
constructs. It will build a VPC with private and public subnets per AZ with the
proper routing and labeling.

For a more details on the design go to [Dynamic VPC Module](https://jq1.io/posts/dynamic_vpc/)

Here is the related VPC network diagram for visual reference.
![example_vpc](https://docs.aws.amazon.com/vpc/latest/userguide/images/nat-gateway-diagram.png)

# Using the VPC module

This configuration will create a VPC in the us-east-1 region with a NAT Gatway per AZ with
routing for each private and public subnets. Every taggable resource
will have proper naming including environment, region and AZ. Everything
is in `main.tf` and `variables.tf` because I wanted less directory structure focus.

Also, I like being explicit about passing in an aliased `provider` into the module. It makes it
easier to identify which region or account I'm applying module resources into.
```
terraform {
  required_version = ">= 0.12.6"
  required_providers {
    aws = "2.70.0"
  }
}

# base provider
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "use1"
}
```
```

variable "region_az_short_names" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type = map(string)

  default = {
    us-east-1  = "use1"
    us-east-1a = "use1a"
    us-east-1b = "use1b"
    us-east-1c = "use1c"
    us-west-2  = "usw2"
    us-west-2a = "usw2a"
    us-west-2b = "usw2b"
    us-west-2c = "usw2c"
  }
}

module "stage_use1_vpc" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/dynamic_vpc?ref=v1.0.0"

  providers = {
    aws = aws.use1
  }

  env_prefix            = "stage"
  region_az_short_names = var.region_az_short_names
  cidr_block            = "10.0.0.0/16"
  azs = {
    a = 1
    b = 2
    c = 3
  }
}
```

Note: The third octet of the private subnets correspond to the values in the
`var.azs` map. The third octect of the public subnets are n + 32.

| az | resource |  subnet cidr | routing
| ----------- | ----------- | ----------- | ----------- |
| a | private subnet| 10.0.1.0/24| traffic routes out nat gateway in AZ a
| a | public subnet|  10.0.33.0/24| traffic routes out igw
| | | |
| b | private subnet| 10.0.2.0/24| traffic routes out nat gateway in AZ b
| b | public subnet|  10.0.34.0/24| traffic routes out igw
| | | |
| c | private subnet| 10.0.3.0/24| traffic routes out nat gateway in AZ c
| c | public subnet|  10.0.35.0/24| traffic routes out igw

## Caveats

This VPC module more of a learning excersize and it does generate resources that cost money (ie NAT Gateways and EIPs).
When it comes to scaling out networks via peer links it's best practice to segment your network tiers with their own subnets per AZ (ie
private app subnet, public load balancer subnet, etc). Network segmentation makes it easier configure security groups across the VPC Peer links
because you can't share security group IDs across VPCs, only subnets!

