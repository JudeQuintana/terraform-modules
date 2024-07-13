# Tiered VPC-NG

`v1.8.2`
- New [Dual Stack Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/dual_stack_networking_trifecta_demo)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.31 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.31 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_egress_only_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/egress_only_internet_gateway) | resource |
| [aws_eip.this_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.this_private_ipv6_route_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_private_route_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_public_ipv6_route_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_public_route_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.this_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.this_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.this_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.this_intra_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.this_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.this_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_ipv4_cidr_block_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_region_az_labels"></a> [region\_az\_labels](#input\_region\_az\_labels) | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional Tags | `map(string)` | `{}` | no |
| <a name="input_tiered_vpc"></a> [tiered\_vpc](#input\_tiered\_vpc) | Tiered VPC configuration | <pre>object({<br>    name = string<br>    # ipv4 requires ipam<br>    ipv4 = object({<br>      network_cidr    = string<br>      secondary_cidrs = optional(list(string), [])<br>      ipam_pool = object({<br>        id = string<br>      })<br>    })<br>    # ipv6 requires ipam<br>    ipv6 = optional(object({<br>      network_cidr = optional(string)<br>      ipam_pool = optional(object({<br>        id = optional(string)<br>      }), {})<br>    }), {})<br>    azs = map(object({<br>      eigw = optional(bool, false)<br>      private_subnets = optional(list(object({<br>        name      = string<br>        cidr      = string<br>        ipv6_cidr = optional(string)<br>        special   = optional(bool, false)<br>      })), [])<br>      public_subnets = optional(list(object({<br>        name      = string<br>        cidr      = string<br>        ipv6_cidr = optional(string)<br>        special   = optional(bool, false)<br>        natgw     = optional(bool, false)<br>      })), [])<br>    }))<br>    enable_dns_support   = optional(bool, true)<br>    enable_dns_hostnames = optional(bool, true)<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | n/a |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | n/a |
| <a name="output_full_name"></a> [full\_name](#output\_full\_name) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_intra_vpc_security_group_id"></a> [intra\_vpc\_security\_group\_id](#output\_intra\_vpc\_security\_group\_id) | n/a |
| <a name="output_ipv6_network_cidr"></a> [ipv6\_network\_cidr](#output\_ipv6\_network\_cidr) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_network_cidr"></a> [network\_cidr](#output\_network\_cidr) | n/a |
| <a name="output_private_ipv6_subnet_cidrs"></a> [private\_ipv6\_subnet\_cidrs](#output\_private\_ipv6\_subnet\_cidrs) | n/a |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | n/a |
| <a name="output_private_special_subnet_ids"></a> [private\_special\_subnet\_ids](#output\_private\_special\_subnet\_ids) | n/a |
| <a name="output_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#output\_private\_subnet\_cidrs) | n/a |
| <a name="output_private_subnet_name_to_subnet_id"></a> [private\_subnet\_name\_to\_subnet\_id](#output\_private\_subnet\_name\_to\_subnet\_id) | n/a |
| <a name="output_public_ipv6_subnet_cidrs"></a> [public\_ipv6\_subnet\_cidrs](#output\_public\_ipv6\_subnet\_cidrs) | n/a |
| <a name="output_public_route_table_ids"></a> [public\_route\_table\_ids](#output\_public\_route\_table\_ids) | n/a |
| <a name="output_public_special_subnet_ids"></a> [public\_special\_subnet\_ids](#output\_public\_special\_subnet\_ids) | n/a |
| <a name="output_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#output\_public\_subnet\_cidrs) | n/a |
| <a name="output_public_subnet_name_to_subnet_id"></a> [public\_subnet\_name\_to\_subnet\_id](#output\_public\_subnet\_name\_to\_subnet\_id) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
| <a name="output_secondary_cidrs"></a> [secondary\_cidrs](#output\_secondary\_cidrs) | n/a |
