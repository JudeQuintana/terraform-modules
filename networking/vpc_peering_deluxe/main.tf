/*
* VPC Peering Deluxe module will create appropriate routes for all subnets in each cross region Tiered VPC-NG by default.
*
* Should also work for intra region VPCs.
*
* Can be used in tandem with Centralized Router, Super Router and Full Mesh Trio for workloads that transfer lots of data to save on cost instead of via TGW.
*
* See it in action in [Full Mesh Trio Demo](https://github.com/JudeQuintana/terraform-main/tree/main/full_mesh_trio_demo)
*
* ```
* module "vpc_peering_deluxe" {
*  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/vpc_peering_deluxe?ref=v1.7.4"
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
* Specific subnet cidrs can be selected (instead of default behavior of allow all subnets) to route across the VPC peering connection via only_route_subnet_cidrs variable list is populated.
*
* Additional option to allow remote dns resolution too.
* ```
* module "vpc_peering_deluxe" {
*  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/vpc_peering_deluxe?ref=v1.7.4"
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
*
* Inter region VPC peering works too, route all subnets across peering connection
* ```
* module "vpc_peering_deluxe_inter_region" {
*  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/vpc_peering_deluxe?ref=v1.7.4"
*
*  providers = {
*    aws.local = aws.usw2
*    aws.peer  = aws.usw2
*  }
*
*  env_prefix         = var.env_prefix
*  vpc_peering_deluxe = {
*    local = {
*      vpc = module.vpc_usw2
*    }
*    peer = {
*      vpc = module.vpc_usw2
*    }
*  }
* }
* ```
*
*
*/
