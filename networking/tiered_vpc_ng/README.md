# Networking Trifecta Demo
Blog Post:
[Terraform Networking Trifecta ](https://jq1.io/posts/tnt/)

Main:
- [Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/networking_trifecta_demo)
  - See [Trifecta Demo Time](https://jq1.io/posts/tnt/#trifecta-demo-time) for instructions.

# Tiered VPC-NG Description
Baseline Tiered VPC-NG features (same as prototype):

- Create VPC tiers
  - It’s much easier to think about tiers ephemerally when scaling out VPCs because we can narrow down the context (ie app, db, general) and maximize the use of smaller network size when needed.
  - You can still have 3 tiered networking (ie lbs, dbs for an app) internally to the VPC.
- VPC resources are IPv4 only.
  - No IPv6 configuration for now.

- Creates structured VPC resource naming and tagging.
  - Ephemeral Naming
  - `<env_prefix>-<region|az>-<tier_name>-<public|private>-<pet_name|misc_label>`

- Requires a minimum of at least one public subnet per AZ.

- Can add and remove subnets and/or AZs at any time*.

- Internal and external VPC routing is automatic.

What’s new in NG?

- An Intra VPC Security Group is created by default.

 - This will be for adding security group rules that are inbound only for access across VPCs.
 - No more nulling out private subnets ie `private = null`.
   - Just populate the list to create them ie `private = []` just like the public subnets.

- NAT Gateways are no longer built by default when private subnets exist in an AZ.
 - This allows for routable private subnets that have no outbound internet traffic unless `enable_natgw = true`, in which case the NAT Gateway will be built and private route tables updated.
 - Now you can just “flip the switch” to give all private subnets in an AZ access to the internet.
 - NAT Gateways are created with an EIP per AZ when enabled.
   - This is why we need at least one public subnet per AZ to create them in.

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
| <a name="provider_random"></a> [random](#provider\_random) | ~>3.1.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_route_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_route_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.intra_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [random_pet.private](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [random_pet.public](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_region_az_labels"></a> [region\_az\_labels](#input\_region\_az\_labels) | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional Tags | `map(string)` | `{}` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | Set VPC Tenancy | `string` | `"default"` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | n/a | <pre>object({<br>    name    = string<br>    network = string<br>    azs = map(object({<br>      enable_natgw = optional(bool)<br>      public       = list(string)<br>      private      = list(string)<br>    }))<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | n/a |
| <a name="output_az_to_private_route_table_id"></a> [az\_to\_private\_route\_table\_id](#output\_az\_to\_private\_route\_table\_id) | n/a |
| <a name="output_az_to_private_subnet_ids"></a> [az\_to\_private\_subnet\_ids](#output\_az\_to\_private\_subnet\_ids) | n/a |
| <a name="output_az_to_public_route_table_id"></a> [az\_to\_public\_route\_table\_id](#output\_az\_to\_public\_route\_table\_id) | n/a |
| <a name="output_az_to_public_subnet_ids"></a> [az\_to\_public\_subnet\_ids](#output\_az\_to\_public\_subnet\_ids) | n/a |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | n/a |
| <a name="output_full_name"></a> [full\_name](#output\_full\_name) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_intra_vpc_security_group_id"></a> [intra\_vpc\_security\_group\_id](#output\_intra\_vpc\_security\_group\_id) | n/a |
| <a name="output_network"></a> [network](#output\_network) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
