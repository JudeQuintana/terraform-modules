VPC Peering Deluxe module will create appropriate routes for all subnets in each cross region Tiered VPC-NG by default.

Should also work for intra region VPCs.

Can be used in tandem with Centralized Router, Super Router and Full Mesh Trio for workloads that transfer lots of data to save on cost instead of via TGW.

See it in action in [Full Mesh Trio Demo](https://github.com/JudeQuintana/terraform-main/tree/main/full_mesh_trio_demo)

```
module "vpc_peering_deluxe" {
 source = "git@github.com:JudeQuintana/terraform-modules.git//networking/vpc_peering_deluxe?ref=v1.7.5"

 providers = {
   aws.local = aws.use1
   aws.peer  = aws.use2
 }

 env_prefix = var.env_prefix
 vpc_peering_deluxe = {
   local = {
     vpc = module.vpc_use1
   }
   peer = {
     vpc = module.vpc_use2
   }
 }
}
```

Specific subnet cidrs can be selected (instead of default behavior of allow all subnets) to route across the VPC peering connection via only\_route\_subnet\_cidrs variable list is populated.

Additional option to allow remote dns resolution too.
```
module "vpc_peering_deluxe" {
 source = "git@github.com:JudeQuintana/terraform-modules.git//networking/vpc_peering_deluxe?ref=v1.7.5"

 providers = {
   aws.local = aws.use1
   aws.peer  = aws.use2
 }

 env_prefix                        = var.env_prefix
 vpc_peering_deluxe                = {
   allow_remote_vpc_dns_resolution = true
   local = {
     vpc                     = module.vpc_use1
     only_route_subnet_cidrs = ["172.16.1.0/24"]
   }
   peer = {
     vpc                     = module.vpc_use2
     only_route_subnet_cidrs = ["192.168.13.0/28"]
   }
 }
}
```

Inter region VPC peering works too, route all subnets across peering connection
```
module "vpc_peering_deluxe_inter_region" {
 source = "git@github.com:JudeQuintana/terraform-modules.git//networking/vpc_peering_deluxe?ref=v1.7.5"

 providers = {
   aws.local = aws.usw2
   aws.peer  = aws.usw2
 }

 env_prefix         = var.env_prefix
 vpc_peering_deluxe = {
   local = {
     vpc = module.vpc_usw2
   }
   peer = {
     vpc = module.vpc_usw2
   }
 }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=4.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.local"></a> [aws.local](#provider\_aws.local) | >=4.20 |
| <a name="provider_aws.peer"></a> [aws.peer](#provider\_aws.peer) | >=4.20 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route.this_ipv6_local_to_this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_ipv6_peer_to_this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_local_to_this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_peer_to_this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_vpc_peering_connection.this_local_to_this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection_accepter.this_local_to_this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_vpc_peering_connection_options.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_options) | resource |
| [aws_vpc_peering_connection_options.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_options) | resource |
| [aws_caller_identity.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Addtional Tags | `map(string)` | `{}` | no |
| <a name="input_vpc_peering_deluxe"></a> [vpc\_peering\_deluxe](#input\_vpc\_peering\_deluxe) | VPC Peering Deluxe configuration. Will create appropriate routes for all subnets in each VPC by default unless specific subnet cidrs are selected to route across the VPC peering connection via only\_route.subnet\_cidrs list is populated. | <pre>object({<br>    allow_remote_vpc_dns_resolution = optional(bool, false)<br>    local = object({<br>      vpc = object({<br>        account_id                = string<br>        full_name                 = string<br>        id                        = string<br>        name                      = string<br>        network_cidr              = string<br>        ipv6_network_cidr         = optional(string)<br>        private_subnet_cidrs      = list(string)<br>        public_subnet_cidrs       = list(string)<br>        private_ipv6_subnet_cidrs = optional(list(string), [])<br>        public_ipv6_subnet_cidrs  = optional(list(string), [])<br>        private_route_table_ids   = list(string)<br>        public_route_table_ids    = list(string)<br>        region                    = string<br>      })<br>      only_route = optional(object({<br>        subnet_cidrs      = optional(list(string), [])<br>        ipv6_subnet_cidrs = optional(list(string), [])<br>      }), {})<br>    })<br>    peer = object({<br>      vpc = object({<br>        account_id                = string<br>        full_name                 = string<br>        id                        = string<br>        name                      = string<br>        network_cidr              = string<br>        ipv6_network_cidr         = optional(string)<br>        private_subnet_cidrs      = list(string)<br>        public_subnet_cidrs       = list(string)<br>        private_ipv6_subnet_cidrs = list(string)<br>        public_ipv6_subnet_cidrs  = list(string)<br>        private_route_table_ids   = list(string)<br>        public_route_table_ids    = list(string)<br>        region                    = string<br>      })<br>      only_route = optional(object({<br>        subnet_cidrs      = optional(list(string), [])<br>        ipv6_subnet_cidrs = optional(list(string), [])<br>      }), {})<br>    })<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_peering"></a> [peering](#output\_peering) | n/a |
