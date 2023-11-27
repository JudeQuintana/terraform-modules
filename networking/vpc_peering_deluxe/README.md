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
| <a name="input_vpc_peering_deluxe"></a> [vpc\_peering\_deluxe](#input\_vpc\_peering\_deluxe) | VPC Peering Deluxe configuration. Will create appropriate routes for all subnets in each VPC by default unless specific subnet cidrs are selected to route across the VPC peering connection via only\_route\_subnet\_cidrs list is populated. | <pre>object({<br>    allow_remote_vpc_dns_resolution = optional(bool, false)<br>    local = object({<br>      vpc = object({<br>        account_id              = string<br>        full_name               = string<br>        id                      = string<br>        name                    = string<br>        network_cidr            = string<br>        private_subnet_cidrs    = list(string)<br>        public_subnet_cidrs     = list(string)<br>        private_route_table_ids = list(string)<br>        public_route_table_ids  = list(string)<br>        region                  = string<br>      })<br>      only_route_subnet_cidrs = optional(list(string), [])<br>    })<br>    peer = object({<br>      vpc = object({<br>        account_id              = string<br>        full_name               = string<br>        id                      = string<br>        name                    = string<br>        network_cidr            = string<br>        private_subnet_cidrs    = list(string)<br>        public_subnet_cidrs     = list(string)<br>        private_route_table_ids = list(string)<br>        public_route_table_ids  = list(string)<br>        region                  = string<br>      })<br>      only_route_subnet_cidrs = optional(list(string), [])<br>    })<br>  })</pre> | n/a | yes |

## Outputs

No outputs.