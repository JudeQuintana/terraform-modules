# Networking Trifecta Demo
Blog Post:
[Terraform Networking Trifecta ](https://jq1.io/posts/tnt/)

Main:
- [Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/networking_trifecta_demo)
- See [Trifecta Demo Time](https://jq1.io/posts/tnt/#trifecta-demo-time) for instructions.

# Transit Gateway Centralized Router Description
- This Transit Gateway Centralized Router module will use the first public subnet in the list for each AZ of that VPC for the VPC attachments to all AZs.
- All attachments will be associated and routes propagated to one TGW Route Table.
- Each Tiered VPC will have all their route tables updated in each VPC with a route to all other VPC networks via the TGW.
- Will generate and add routes in each VPC to all other networks.

Example:
```
module "centralized_router" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/transit_gateway_centralized_router_for_tiered_vpc_ng?ref=moar-better"

  env_prefix       = var.env_prefix
  region_az_labels = var.region_az_labels
  centralized_router = {
    name            = "bishop"
    amazon_side_asn = 64512
    blackhole_cidrs = ["172.16.8.0/24"]
    vpcs            = module.vpcs
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=4.20 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_generate_routes_to_other_vpcs"></a> [generate\_routes\_to\_other\_vpcs](#module\_generate\_routes\_to\_other\_vpcs) | git@github.com:JudeQuintana/terraform-modules.git//utils/generate_routes_to_other_vpcs | moar-better |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_route.this_blackholes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_route.this_vpc_routes_to_other_vpcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_centralized_router"></a> [centralized\_router](#input\_centralized\_router) | Centralized Router configuration | <pre>object({<br>    name            = string<br>    amazon_side_asn = number<br>    blackhole_cidrs = optional(list(string), [])<br>    vpcs = optional(map(object({<br>      account_id                = string<br>      private_route_table_ids   = list(string)<br>      public_route_table_ids    = list(string)<br>      public_special_subnet_ids = list(string)<br>      full_name                 = string<br>      id                        = string<br>      name                      = string<br>      network_cidr              = string<br>      region                    = string<br>    })), {})<br>  })</pre> | n/a | yes |
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_region_az_labels"></a> [region\_az\_labels](#input\_region\_az\_labels) | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional Tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | n/a |
| <a name="output_amazon_side_asn"></a> [amazon\_side\_asn](#output\_amazon\_side\_asn) | n/a |
| <a name="output_blackhole_cidrs"></a> [blackhole\_cidrs](#output\_blackhole\_cidrs) | n/a |
| <a name="output_full_name"></a> [full\_name](#output\_full\_name) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
| <a name="output_route_table_id"></a> [route\_table\_id](#output\_route\_table\_id) | n/a |
| <a name="output_vpc_network_cidrs"></a> [vpc\_network\_cidrs](#output\_vpc\_network\_cidrs) | n/a |
| <a name="output_vpc_routes"></a> [vpc\_routes](#output\_vpc\_routes) | route object will only have 3 attributes instead of all attributes from the route makes it easier to see when troubleshooting many vpc routes otherwise it can just be [for this in aws\_route.this\_vpc\_routes\_to\_other\_vpcs : this] |
| <a name="output_vpcs"></a> [vpcs](#output\_vpcs) | n/a |
