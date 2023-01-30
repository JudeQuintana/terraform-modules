# Super Router Description
This is a follow up to the [generating routes post](https://jq1.io/posts/generating_routes/).

Original Blog Post: [Super Powered, Super Sharp, Super Router!](https://jq1.io/posts/super_router/)

Fresh new decentralized design in [$init super refactor](https://jq1.io/posts/init_super_refactor/).

New features means new steez in [Slappin chrome on the WIP'](https://jq1.io/posts/slappin_chrome_on_the_wip/)!

Super Router provides both intra-region and cross-region peering and routing for Centralized Routers and Tiered VPCs (same AWS account only, no cross account).

Super Router is composed of two TGWs instead of one TGW (one for each region).

Example:
```
module "super_router_usw2_to_use1" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/tgw_super_router_for_tgw_centralized_router?ref=v1.4.6"

  providers = {
    aws.local = aws.usw2 # local super router tgw will be built in the aws.local provider region
    aws.peer  = aws.use1 # peer super router tgw will be built in the aws.peer provider region
  }

  env_prefix       = var.env_prefix
  region_az_labels = var.region_az_labels
  super_router = {
    name = "professor-x"
    local = {
      amazon_side_asn     = 64521
      centralized_routers = module.centralized_routers_usw2
    }
    peer = {
      amazon_side_asn     = 64522
      centralized_routers = module.centralized_routers_use1
    }
  }
}

*
```

![super-router](https://jq1.io/img/super-refactor-shokunin.png)

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
| [aws_ec2_transit_gateway.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_peering_attachment.this_local_to_locals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment.this_local_to_this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment.this_peer_to_peers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_peers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_route.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_local_blackholes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_local_tgw_routes_to_local_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_local_tgw_routes_to_vpcs_in_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_local_to_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_blackholes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_tgw_routes_to_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_tgw_routes_to_vpcs_in_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_to_local_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_local_to_locals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_local_to_this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_peer_to_peers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_peer_to_this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_route.this_local_vpc_routes_to_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_local_vpcs_routes_to_local_vpcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_peer_vpc_routes_to_local_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_peer_vpcs_routes_to_peer_vpcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_caller_identity.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ec2_transit_gateway_peering_attachment.this_local_to_locals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_transit_gateway_peering_attachment) | data source |
| [aws_ec2_transit_gateway_peering_attachment.this_peer_to_peers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_transit_gateway_peering_attachment) | data source |
| [aws_region.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_region_az_labels"></a> [region\_az\_labels](#input\_region\_az\_labels) | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |
| <a name="input_super_router"></a> [super\_router](#input\_super\_router) | Super Router configuration | <pre>object({<br>    name            = string<br>    blackhole_cidrs = optional(list(string), [])<br>    local = object({<br>      amazon_side_asn = number<br>      centralized_routers = optional(map(object({<br>        account_id        = string<br>        amazon_side_asn   = string<br>        full_name         = string<br>        id                = string<br>        name              = string<br>        region            = string<br>        route_table_id    = string<br>        vpc_names         = list(string)<br>        vpc_network_cidrs = list(string)<br>        vpc_routes = list(object({<br>          route_table_id         = string<br>          destination_cidr_block = string<br>          transit_gateway_id     = string<br>        }))<br>        vpcs = map(object({<br>          network_cidr            = string<br>          private_route_table_ids = list(string)<br>          public_route_table_ids  = list(string)<br>        }))<br>      })), {})<br>    })<br>    peer = object({<br>      amazon_side_asn = number<br>      centralized_routers = optional(map(object({<br>        account_id        = string<br>        amazon_side_asn   = string<br>        full_name         = string<br>        id                = string<br>        name              = string<br>        region            = string<br>        route_table_id    = string<br>        vpc_names         = list(string)<br>        vpc_network_cidrs = list(string)<br>        vpc_routes = list(object({<br>          route_table_id         = string<br>          destination_cidr_block = string<br>          transit_gateway_id     = string<br>        }))<br>        vpcs = map(object({<br>          network_cidr            = string<br>          private_route_table_ids = list(string)<br>          public_route_table_ids  = list(string)<br>        }))<br>      })), {})<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional Tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_blackhole_cidrs"></a> [blackhole\_cidrs](#output\_blackhole\_cidrs) | n/a |
| <a name="output_local"></a> [local](#output\_local) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_peer"></a> [peer](#output\_peer) | n/a |
