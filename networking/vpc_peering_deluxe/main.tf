/*
* VPC Peering Deluxe module will create appropriate routes for all subnets in each cross region VPC by default.
* Should also work for intra region VPCs.
* ```
* module "vpc_peering_deluxe" {
*  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/vpc_peering_deluxe?ref=v1.6.0"
*
*  providers = {
*    aws.local = aws.use1
*    aws.peer  = aws.use2
*  }
*
*  env_prefix = var.env_prefix
*  vpc_peering_deluxe = {
*    local = {
*      vpc = module.vpc_use1
*    }
*    peer = {
*      vpc = module.vpc_use2
*    }
*  }
* }
* ```
*
* Specific subnet cidrs can be selected (instead of default behavior of allow all subnets) to route across the VPC peering connection via var.only_route_subnet_cidrs list is populated.
* Additional option to allow remote dns resolution too.
* ```
* module "vpc_peering_deluxe" {
*  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/vpc_peering_deluxe?ref=v1.6.0"
*
*  providers = {
*    aws.local = aws.use1
*    aws.peer  = aws.use2
*  }
*
*  env_prefix                        = var.env_prefix
*  vpc_peering_deluxe                = {
*    allow_remote_vpc_dns_resolution = true
*    local = {
*      vpc                     = module.vpc_use1
*      only_route_subnet_cidrs = ["172.16.1.0/24"]
*    }
*    peer = {
*      vpc                     = module.vpc_use2
*      only_route_subnet_cidrs = ["192.168.13.0/28"]
*    }
*  }
* }
* ```
*/
