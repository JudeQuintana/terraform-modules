# Networking Trifecta Demo
Blog Post:
[Terraform Networking Trifecta ](https://jq1.io/posts/tnt/)

Main:
- [Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/networking_trifecta_demo)
  - See [Trifecta Demo Time](https://jq1.io/posts/tnt/#trifecta-demo-time) for instructions.

# Tiered VPC-NG Description
Baseline Tiered VPC-NG features (same as prototype):

- Create VPC tiers
  - Thinking about VPCs as tiers helps narrow down the context (ie app, db, general) and maximize the use of smaller network size when needed.
  - You can still have 3 tiered networking (ie lbs, dbs for an app) internally to the VPC.
- VPC resources are IPv4 only.
  - No IPv6 configuration for now.

- Creates structured VPC resource naming and tagging.
  - `<env_prefix>-<tier_name>-<public|private>-<region|az>`

- An Intra VPC Security Group is created by default.
 - This will be for adding security group rules that are inbound only for access across VPCs.

- Can add, remove, name and rename sunbnets*.

- Requires a minimum of at least one public subnet per AZ.
  - When a NAT Gateway is enabled for an AZ it will be built in the public subnet with the `special = true` attribute for an AZ by default. There can only be one public subnet with `special = true` per AZ.
    - Set `enable_natgw` in an AZ to give all private subnets in an AZ access to the internet, in which case the NAT Gateway will be built with EIP allocated and private route tables updated.
  - When a Tiered VPC is passed to a Centralized Router, the VPC attachment will also use the public subnet with the `special = true` attribute for each AZ of that VPC by default.
  - The trade off is always having to allocate at least one public subnet per AZ, even if the you don't need to use it (ie using private subnets only).
  - I highly recommend naming and allocating a small subnet like a /28 and setting it's special attribute to true (ie `public_subnets = [{name = "natwgw", cidr = "10.0.9.64/28", special = true}, {name = "haproxy1", cidr = "10.0.10.0/24"}]`.
  - Subnets can only be deleted when they are not in use (ie natgws, vpc attachment, ec2 instances, or some other aws server).

- Recommendations:
  - all vpc names and network cidrs should be unique across regions
  - the routers will enforce uniqueness along with other validations

Example:
```
locals {
  tiered_vpcs = [
    {
      name         = "app"
      network_cidr = "10.0.0.0/20"
      azs = {
        a = {
          private_subnets = [
            { name = "cluster1", cidr = "10.0.0.0/24" }
          ]
          public_subnets = [
            { name = "random1", cidr = "10.0.3.0/28" },
            { name = "haproxy1", cidr = "10.0.4.0/26" }
            { name = "natgw", cidr = "10.0.10.0/28", special = true }
          ]
        }
        b = {
          private_subnets = [
            { name = "cluster2", cidr = "10.0.1.0/24" },
            { name = "random2", cidr = "10.0.5.0/24" }
          ]
          public_subnets = [
            { name = "random3", cidr = "10.0.6.0/24", special = true}
          ]
        }
      }
    },
    {
      name         = "cicd"
      network_cidr = "172.16.0.0/20"
      azs = {
        b = {
          enable_natgw = true
          private_subnets = [
            { name = "jenkins1", cidr = "172.16.5.0/24" }
          ]
          public_subnets = [
            { name = "natgw", cidr = "172.16.8.0/28", special = true }
          ]
        }
      }
    },
    {
      name         = "general"
      network_cidr = "192.168.0.0/20"
      azs = {
        c = {
          private_subnets = [
            { name = "db1", cidr = "192.168.10.0/24" }
          ]
          public_subnets = [
            { name = "random1", cidr = "192.168.13.0/28", special = true }
          ]
        }
      }
    }
  ]
}

module "vpcs" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/tiered_vpc_ng?ref=moar-better"

  for_each = { for t in local.tiered_vpcs : t.name => t }

  env_prefix       = var.env_prefix
  region_az_labels = var.region_az_labels
  tiered_vpc       = each.value
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.20 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.this_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.public_route_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_private_route_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.this_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.this_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.this_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.this_intra_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.this_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.this_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_region_az_labels"></a> [region\_az\_labels](#input\_region\_az\_labels) | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional Tags | `map(string)` | `{}` | no |
| <a name="input_tiered_vpc"></a> [tiered\_vpc](#input\_tiered\_vpc) | Tiered VPC configuration | <pre>object({<br>    name         = string<br>    network_cidr = string<br>    tenancy      = optional(string, "default")<br>    azs = map(object({<br>      enable_natgw = optional(bool, false)<br>      private_subnets = optional(list(object({<br>        name = string<br>        cidr = string<br>      })), [])<br>      public_subnets = list(object({<br>        name    = string<br>        cidr    = string<br>        special = optional(bool, false)<br>      }))<br>    }))<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | n/a |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | n/a |
| <a name="output_full_name"></a> [full\_name](#output\_full\_name) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_intra_vpc_security_group_id"></a> [intra\_vpc\_security\_group\_id](#output\_intra\_vpc\_security\_group\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_network_cidr"></a> [network\_cidr](#output\_network\_cidr) | n/a |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | n/a |
| <a name="output_private_subnet_name_to_subnet_id"></a> [private\_subnet\_name\_to\_subnet\_id](#output\_private\_subnet\_name\_to\_subnet\_id) | n/a |
| <a name="output_public_route_table_ids"></a> [public\_route\_table\_ids](#output\_public\_route\_table\_ids) | n/a |
| <a name="output_public_special_subnet_ids"></a> [public\_special\_subnet\_ids](#output\_public\_special\_subnet\_ids) | n/a |
| <a name="output_public_subnet_name_to_subnet_id"></a> [public\_subnet\_name\_to\_subnet\_id](#output\_public\_subnet\_name\_to\_subnet\_id) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
