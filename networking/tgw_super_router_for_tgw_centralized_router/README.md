## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.20 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.local"></a> [aws.local](#provider\_aws.local) | ~>4.20 |
| <a name="provider_aws.peer"></a> [aws.peer](#provider\_aws.peer) | ~>4.20 |
| <a name="provider_random"></a> [random](#provider\_random) | ~>3.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_peering_attachment.this_local_to_locals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment.this_local_to_peers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_locals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_route.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_local_tgw_routes_to_local_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_local_tgw_routes_to_vpcs_in_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_tgw_routes_to_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_tgw_routes_to_vpcs_in_local_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_vpc_to_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_local_to_locals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_peer_to_locals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_route.this_local_vpc_routes_to_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_local_vpcs_routes_to_local_vpcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_peer_vpc_routes_to_local_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_peer_vpcs_routes_to_peer_vpcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_caller_identity.this_local_current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ec2_transit_gateway_peering_attachment.this_local_to_locals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_transit_gateway_peering_attachment) | data source |
| [aws_region.this_local_current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_local_amazon_side_asn"></a> [local\_amazon\_side\_asn](#input\_local\_amazon\_side\_asn) | required local amazon side asn | `number` | n/a | yes |
| <a name="input_local_centralized_routers"></a> [local\_centralized\_routers](#input\_local\_centralized\_routers) | list of centralized router objects for local provider | <pre>list(object({<br>    account_id      = string<br>    amazon_side_asn = string<br>    full_name       = string<br>    id              = string<br>    networks        = list(string)<br>    region          = string<br>    route_table_id  = string<br>    vpc_routes = list(object({<br>      route_table_id         = string<br>      destination_cidr_block = string<br>      transit_gateway_id     = string<br>    }))<br>    vpcs = map(object({<br>      network                      = string<br>      az_to_public_route_table_id  = map(string)<br>      az_to_private_route_table_id = map(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_peer_centralized_routers"></a> [peer\_centralized\_routers](#input\_peer\_centralized\_routers) | list of centralized router objects for remote provider | <pre>list(object({<br>    account_id      = string<br>    amazon_side_asn = string<br>    full_name       = string<br>    id              = string<br>    networks        = list(string)<br>    region          = string<br>    route_table_id  = string<br>    vpc_routes = list(object({<br>      route_table_id         = string<br>      destination_cidr_block = string<br>      transit_gateway_id     = string<br>    }))<br>    vpcs = map(object({<br>      network                      = string<br>      az_to_public_route_table_id  = map(string)<br>      az_to_private_route_table_id = map(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_region_az_labels"></a> [region\_az\_labels](#input\_region\_az\_labels) | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional Tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_full_name"></a> [full\_name](#output\_full\_name) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_local_account_id"></a> [local\_account\_id](#output\_local\_account\_id) | n/a |
| <a name="output_local_region"></a> [local\_region](#output\_local\_region) | n/a |
| <a name="output_networks"></a> [networks](#output\_networks) | n/a |
| <a name="output_route_table_id"></a> [route\_table\_id](#output\_route\_table\_id) | n/a |
