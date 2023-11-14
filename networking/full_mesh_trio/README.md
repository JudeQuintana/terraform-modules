Full Mesh Trio module builds peering links (red) between existing hub spoke tgws (Centralized Routers) and adds proper routes to all TGWs and their attached VPCs, etc.

The resulting architecture is a full mesh configurion between 3 hub spoke topologies:
![full-mesh-trio](https://jq1-io.s3.amazonaws.com/full-mesh-trio/full-mesh-trio.png)

See it in action in the [Full Mesh Trio Demo](https://github.com/JudeQuintana/terraform-main/tree/main/full_mesh_trio_demo)

```
module "full_mesh_trio" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/full_mesh_trio?ref=v1.5.0"

  providers = {
    aws.one   = aws.use1
    aws.two   = aws.use2
    aws.three = aws.usw2
  }

 env_prefix = var.env_prefix
 full_mesh_trio = {
   one = {
     centralized_router = module.centralized_router_use1
   }
   two = {
     centralized_router = module.centralized_router_use2
   }
   three = {
     centralized_router = module.centralized_router_usw2
   }
 }
}

output "full_mesh_trio" {
 value = module.full_mesh_trio
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
| <a name="provider_aws.one"></a> [aws.one](#provider\_aws.one) | >=4.20 |
| <a name="provider_aws.three"></a> [aws.three](#provider\_aws.three) | >=4.20 |
| <a name="provider_aws.two"></a> [aws.two](#provider\_aws.two) | >=4.20 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway_peering_attachment.this_one_to_this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment.this_three_to_this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment.this_two_to_this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this_one_to_this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this_three_to_this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_route.this_one_tgw_routes_to_vpcs_in_three_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_one_tgw_routes_to_vpcs_in_two_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_three_tgw_routes_to_vpcs_in_one_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_three_tgw_routes_to_vpcs_in_two_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_two_tgw_routes_to_vpcs_in_one_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_two_tgw_routes_to_vpcs_in_three_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_one_to_this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_one_to_this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_three_to_this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_three_to_this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_two_to_this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_two_to_this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_route.this_one_vpc_routes_to_three_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_one_vpc_routes_to_two_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_three_vpc_routes_to_one_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_three_vpc_routes_to_two_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_two_vpc_routes_to_one_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_two_vpc_routes_to_three_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_caller_identity.this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_full_mesh_trio"></a> [full\_mesh\_trio](#input\_full\_mesh\_trio) | full mesh trio configuration | <pre>object({<br>    one = object({<br>      centralized_router = object({<br>        account_id      = string<br>        amazon_side_asn = string<br>        full_name       = string<br>        id              = string<br>        name            = string<br>        region          = string<br>        route_table_id  = string<br>        vpc = object({<br>          names         = list(string)<br>          network_cidrs = list(string)<br>          routes = list(object({<br>            route_table_id         = string<br>            destination_cidr_block = string<br>            transit_gateway_id     = string<br>          }))<br>        })<br>      })<br>    })<br>    two = object({<br>      centralized_router = object({<br>        account_id      = string<br>        amazon_side_asn = string<br>        full_name       = string<br>        id              = string<br>        name            = string<br>        region          = string<br>        route_table_id  = string<br>        vpc = object({<br>          names         = list(string)<br>          network_cidrs = list(string)<br>          routes = list(object({<br>            route_table_id         = string<br>            destination_cidr_block = string<br>            transit_gateway_id     = string<br>          }))<br>        })<br>      })<br>    })<br>    three = object({<br>      centralized_router = object({<br>        account_id      = string<br>        amazon_side_asn = string<br>        full_name       = string<br>        id              = string<br>        name            = string<br>        region          = string<br>        route_table_id  = string<br>        vpc = object({<br>          names         = list(string)<br>          network_cidrs = list(string)<br>          routes = list(object({<br>            route_table_id         = string<br>            destination_cidr_block = string<br>            transit_gateway_id     = string<br>          }))<br>        })<br>      })<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional Tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_peering"></a> [peering](#output\_peering) | output routes? |
