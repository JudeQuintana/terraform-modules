## Networking Trifecta Demo
Blog Post:
[Terraform Networking Trifecta ](https://jq1.io/posts/tiered_vpc/)

Main:
- [Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/networking_trifecta_demo)
  - See [Trifecta Demo Time](/posts/tnt/#trifecta-demo-time) for instructions.

# Description
This Transit Gateway Centralized Router module will attach all AZs in each Tiered VPC to the TGW.
All attachments will be associated and routes propagated to one TGW Route Table.
Each Tiered VPC will have all their route tables updated in each VPC with a route to all other VPC networks via
the TGW.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.4 |
| aws | ~> 3.53.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.53.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| amazon\_side\_asn | n/a | `number` | `null` | no |
| env\_prefix | prod, stage, etc | `string` | n/a | yes |
| region\_az\_labels | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |
| vpcs | map of tiered\_vpc\_ng objects | <pre>map(object({<br>    id                           = string<br>    network                      = string<br>    az_to_private_route_table_id = map(string)<br>    az_to_private_subnet_ids     = map(list(string))<br>    az_to_public_route_table_id  = map(string)<br>    az_to_public_subnet_ids      = map(list(string))<br>  }))</pre> | n/a | yes |
| tags | Additional Tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | n/a |
| route\_table\_id | n/a |
