# Networking Trifecta Demo
Blog Post:
[Terraform Networking Trifecta ](https://jq1.io/posts/tnt/)

Main:
- [Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/networking_trifecta_demo)
  - See [Trifecta Demo Time](https://jq1.io/posts/tnt/#trifecta-demo-time) for instructions.

# Transit Gateway Centralized Router Description
This Transit Gateway Centralized Router module will attach all AZs in each Tiered VPC to the TGW.
All attachments will be associated and routes propagated to one TGW Route Table.
Each Tiered VPC will have all their route tables updated in each VPC with a route to all other VPC networks via
the TGW.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.20 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~>4.20 |
| <a name="provider_random"></a> [random](#provider\_random) | ~>3.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_generate_routes_to_other_vpcs"></a> [generate\_routes\_to\_other\_vpcs](#module\_generate\_routes\_to\_other\_vpcs) | git@github.com:JudeQuintana/terraform-modules.git//utils/generate_routes_to_other_vpcs | v1.3.3 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amazon_side_asn"></a> [amazon\_side\_asn](#input\_amazon\_side\_asn) | required local amazon side asn | `number` | n/a | yes |
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_region_az_labels"></a> [region\_az\_labels](#input\_region\_az\_labels) | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional Tags | `map(string)` | `{}` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | map of tiered\_vpc\_ng objects | <pre>map(object({<br>    account_id                   = string<br>    region                       = string<br>    id                           = string<br>    full_name                    = string<br>    network                      = string<br>    az_to_private_route_table_id = map(string)<br>    az_to_private_subnet_ids     = map(list(string))<br>    az_to_public_route_table_id  = map(string)<br>    az_to_public_subnet_ids      = map(list(string))<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | n/a |
| <a name="output_amazon_side_asn"></a> [amazon\_side\_asn](#output\_amazon\_side\_asn) | n/a |
| <a name="output_full_name"></a> [full\_name](#output\_full\_name) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_networks"></a> [networks](#output\_networks) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
| <a name="output_route_table_id"></a> [route\_table\_id](#output\_route\_table\_id) | n/a |
| <a name="output_vpc_routes"></a> [vpc\_routes](#output\_vpc\_routes) | n/a |
| <a name="output_vpcs"></a> [vpcs](#output\_vpcs) | n/a |
