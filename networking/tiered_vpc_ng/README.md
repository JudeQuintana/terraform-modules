# Tiered VPC-NG
`v1.9.0`
- support for IPv6 secondary cidrs.
- minor internal changes.
- configurate looks the same as the `v1.8.2` example but with IPv6 secondary cidrs defined
```
    ipv6 = {
      network_cidr    = "2600:1f24:66:c000::/56"
      secondary_cidrs = ["2600:1f24:66:c800::/56"]
      ipam_pool       = local.ipv6_ipam_pool
    }
```

`v1.8.2`
- New [Dual Stack Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/dual_stack_networking_trifecta_demo)
- Requires IPAM Pools for both IPv4 and IPv6 cidrs.
  - Advanced Tier recommended.
  - can start with IPv4 only then add IPv6 at a later time, or start with both.
- EIGW is similar to NATGW but for IPv6 subnets but there can only be EIGW per VPC so any AZ with `eigw = true` is opt-in.
  for private IPv6 subnets per AZ to route to the internet.
- IGW continues to auto toggle if public subnets (ipv4 or ipv6) are defined.
- `special = true` can be assigned to a secondary subnet cidr (public or private).
  - Can be used as a vpc attachemnt when passed to centralized router.
- EIPs dont use a public pool and will continue to be AWS owned public IPv4 cidrs

`v1.8.2` example:
```
# ipam was set up manually (advanced tier)
data "aws_vpc_ipam_pool" "ipv4" {
  filter {
    name   = "description"
    values = ["ipv4-test"]
  }
  filter {
    name   = "address-family"
    values = ["ipv4"]
  }
}

data "aws_vpc_ipam_pool" "ipv6" {
  filter {
    name   = "description"
    values = ["ipv6-test"]
  }
  filter {
    name   = "address-family"
    values = ["ipv6"]
  }
}

locals {
  ipv4_ipam_pool = data.aws_vpc_ipam_pool.ipv4
  ipv6_ipam_pool = data.aws_vpc_ipam_pool.ipv6
}

# ipv4 and ipv6 must use an ipam pool
# can start with ipv4 only and then add ipv6 later if needed.
# vpcs with an ipv4 network cidr /18 provides /20 subnet for each AZ.
locals {
  tiered_vpcs = [
    {
      name = "app"
      ipv4 = {
        network_cidr    = "10.0.0.0/18"
        secondary_cidrs = ["10.1.0.0/18"]
        ipam_pool       = local.ipv4_ipam_pool
      }
      ipv6 = {
        network_cidr = "2600:1f24:66:c000::/56"
        ipam_pool    = local.ipv6_ipam_pool
      }
      azs = {
        a = {
          #eigw = true # opt-in ipv6 private subnets to route out eigw per az
          private_subnets = [
            { name = "another", cidr = "10.0.9.0/24", ipv6_cidr = "2600:1f24:66:c008::/64" }
          ]
          # Enable a NAT Gateway for all private subnets in the same AZ
          # by adding the `natgw = true` attribute to any public subnet
          # `special` and `natgw` can also be enabled together on a public subnet
          public_subnets = [
            { name = "random1", cidr = "10.0.3.0/28", ipv6_cidr = "2600:1f24:66:c000::/64" },
            { name = "haproxy1", cidr = "10.0.4.0/26", ipv6_cidr = "2600:1f24:66:c001::/64" },
            { name = "other", cidr = "10.0.10.0/28", ipv6_cidr = "2600:1f24:66:c002::/64", special = true }
          ]
        }
        b = {
          #eigw = true # opt-in ipv6 private subnets to route out eigw per az
          private_subnets = [
            { name = "cluster2", cidr = "10.0.16.0/24", ipv6_cidr = "2600:1f24:66:c006::/64" },
            { name = "random2", cidr = "10.0.17.0/24", ipv6_cidr = "2600:1f24:66:c007::/64" },
            # special can be assigned to a secondary cidr subnet and be used as a vpc attachemnt when passed to centralized router
            { name = "random3", cidr = "10.1.16.0/24", ipv6_cidr = "2600:1f24:66:c009::/64", special = true }
          ]
        }
      }
    },
    {
      name = "general"
      ipv4 = {
        network_cidr = "192.168.0.0/18"
        ipam_pool    = local.ipv4_ipam_pool
      }
      ipv6 = {
        network_cidr = "2600:1f24:66:c100::/56"
        ipam_pool    = local.ipv6_ipam_pool
      }
      azs = {
        c = {
          #eigw = true # opt-in ipv6 private subnets to route out eigw per az
          private_subnets = [
            { name = "db1", cidr = "192.168.10.0/24", ipv6_cidr = "2600:1f24:66:c100::/64", special = true },
            { name = "db2", cidr = "192.168.11.0/24", ipv6_cidr = "2600:1f24:66:c101::/64" }
          ]
          public_subnets = [
            { name = "other2", cidr = "192.168.14.0/28", ipv6_cidr = "2600:1f24:66:c108::/64" }
          ]
        }
      }
    },
    {
      name = "cicd"
      ipv4 = {
        network_cidr    = "172.16.0.0/18"
        secondary_cidrs = ["172.19.0.0/18"] # aws recommends not using 172.17.0.0/16
        ipam_pool       = local.ipv4_ipam_pool
      }
      ipv6 = {
        network_cidr = "2600:1f24:66:c200::/56"
        ipam_pool    = local.ipv6_ipam_pool
      }
      azs = {
        b = {
          eigw = true # opt-in ipv6 private subnets to route out eigw per az
          private_subnets = [
            { name = "jenkins1", cidr = "172.16.5.0/24", ipv6_cidr = "2600:1f24:66:c200::/64" },
            { name = "experiment1", cidr = "172.19.5.0/24", ipv6_cidr = "2600:1f24:66:c202::/64" }
          ]
          public_subnets = [
            { name = "other", cidr = "172.16.8.0/28", ipv6_cidr = "2600:1f24:66:c207::/64", special = true },
            # build natgw in public subnet for private ipv4 subnets to route out igw per az
            { name = "natgw", cidr = "172.16.16.16/28", ipv6_cidr = "2600:1f24:66:c208::/64", natgw = true }
          ]
        }
      }
    }
  ]
}

module "vpcs" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/tiered_vpc_ng?ref=v1.8.2"

  for_each = { for t in local.tiered_vpcs : t.name => t }

  env_prefix       = var.env_prefix
  region_az_labels = var.region_az_labels
  tiered_vpc       = each.value
}
```

`v1.8.1`
- Private subnets now have a `special` attribute option like the public subnets.
  - Now AZs can have private subnets only, public subnets only or both!
  - Only 1 subnet, private or public can have `special = true` for VPC attachments per AZ when passed to Centralized Router `v1.8.1`.
  - Private route tables are built per AZ

- Public subnets now have a `natgw` attribute insted of having `enable_natgw`.
  - Tag any public subnet with `natgw = true` to build the NATGW for all private subnets within the same AZ.
  - `special` and `natgw` attributes can also be enabled together on a public subnet
  - Only one public route table is built and shared across all public subnets in the VPC.

- IGW now auto toggles if any public subnets are defined.
- Set required `aws` provider version to >=5.31 and Terraform version >=1.4
- Update deprecated `aws_eip` attribute
- Not ideal to migrate to `v1.8.1` since there are many resource naming changes.
  - Didnt have time figure out a move block migration.
  - Recommend starting fresh at `v1.8.1`

`v1.8.1` example:
```
locals {
  tiered_vpcs = [
    {
      name         = "app"
      network_cidr = "10.0.0.0/20"
      azs = {
        a = {
          public_subnets = [
            { name = "random1", cidr = "10.0.3.0/28" },
            { name = "haproxy1", cidr = "10.0.4.0/26" },
            { name = "other", cidr = "10.0.10.0/28", special = true }
          ]
        }
        b = {
          private_subnets = [
            { name = "cluster2", cidr = "10.0.1.0/24" },
            { name = "random2", cidr = "10.0.5.0/24", special = true }
          ]
        }
      }
    },
    {
      name         = "cicd"
      network_cidr = "172.16.0.0/20"
      azs = {
        b = {
          private_subnets = [
            { name = "jenkins1", cidr = "172.16.5.0/24" }
          ]
          public_subnets = [
            { name = "other", cidr = "172.16.8.0/28", special = true },
            { name = "natgw", cidr = "172.16.8.16/28", natgw = true }
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
            { name = "db1", cidr = "192.168.10.0/24", special = true }
          ]
        }
      }
    }
  ]
}

module "vpcs" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/tiered_vpc_ng?ref=v1.8.1"

  for_each = { for t in local.tiered_vpcs : t.name => t }

  env_prefix       = var.env_prefix
  region_az_labels = var.region_az_labels
  tiered_vpc       = each.value
}
```

`v1.8.0`
- Create VPC tiers
  - Thinking about VPCs as tiers helps narrow down the context (ie app, db, general) and maximize the use of smaller network size when needed.
  - You can still have 3 tiered networking (ie lbs, dbs for an app) internally to the VPC.
- VPC resources are IPv4 only.
  - No IPv6 configuration for now.

- Creates structured VPC resource naming and tagging.
  - `<env_prefix>-<tier_name>-<public|private>-<region|az>`

- An Intra VPC Security Group is created by default.
 - This will be for adding security group rules that are inbound only for access across VPCs.

- Can access subnet id by subnet name map via output.
- Can rename public and private subnets directly without forcing a new subnet resource.
- Public subnets now have a special attribute option.
  - Only one can have `special = true`
  - Associate a NAT Gateway if `enable_natgw = true`.
    - Use for associating VPC attatchments when Tiered VPC is passed to a Centralized Router (one in each AZ).
     - Existing public subnets can be rearranged in any order in their repective subnet list without forcing new resources.
  - The trade off is always having to allocate one public subnet per AZ, even if you don’t need to use it (ie using private subnets only).
- Important:
  - All VPC names should be unique across regions (validation enforced).
  - I highly recommend allocating a small public subnet like a /28 and setting it’s special attribute to true for each AZ.
  - Subnets can only be deleted when they are not in use (ie natgws, vpc attachment, ec2 instances, or some other aws server).

- Recommendations:
  - all vpc names and network cidrs should be unique across regions
  - the routers will enforce uniqueness along with other validations

`v1.8.0` example:
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
            { name = "haproxy1", cidr = "10.0.4.0/26" },
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
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/tiered_vpc_ng?ref=v1.8.0"

  for_each = { for t in local.tiered_vpcs : t.name => t }

  env_prefix       = var.env_prefix
  region_az_labels = var.region_az_labels
  tiered_vpc       = each.value
}
```

# Networking Trifecta Demo
Blog Post:
[Terraform Networking Trifecta ](https://jq1.io/posts/tnt/)

Main:
- [Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/networking_trifecta_demo)
  - See [Trifecta Demo Time](https://jq1.io/posts/tnt/#trifecta-demo-time) for instructions.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.61 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.61 |

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
| [aws_route_table.this_isolated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.this_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.this_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this_isolated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.this_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.this_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.this_intra_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.this_isolated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.this_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.this_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_ipv4_cidr_block_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |
| [aws_vpc_ipv6_cidr_block_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv6_cidr_block_association) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_region_az_labels"></a> [region\_az\_labels](#input\_region\_az\_labels) | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional Tags | `map(string)` | `{}` | no |
| <a name="input_tiered_vpc"></a> [tiered\_vpc](#input\_tiered\_vpc) | Tiered VPC configuration | <pre>object({<br/>    name = string<br/>    # ipv4 requires ipam<br/>    ipv4 = object({<br/>      network_cidr    = string<br/>      secondary_cidrs = optional(list(string), [])<br/>      ipam_pool = object({<br/>        id = string<br/>      })<br/>    })<br/>    # ipv6 requires ipam<br/>    ipv6 = optional(object({<br/>      network_cidr    = optional(string)<br/>      secondary_cidrs = optional(list(string), [])<br/>      ipam_pool = optional(object({<br/>        id = optional(string)<br/>      }), {})<br/>    }), {})<br/>    azs = map(object({<br/>      eigw = optional(bool, false)<br/>      isolated_subnets = optional(list(object({<br/>        name      = string<br/>        cidr      = string<br/>        ipv6_cidr = optional(string)<br/>      })), [])<br/>      private_subnets = optional(list(object({<br/>        name      = string<br/>        cidr      = string<br/>        ipv6_cidr = optional(string)<br/>        special   = optional(bool, false)<br/>      })), [])<br/>      public_subnets = optional(list(object({<br/>        name      = string<br/>        cidr      = string<br/>        ipv6_cidr = optional(string)<br/>        special   = optional(bool, false)<br/>        natgw     = optional(bool, false)<br/>      })), [])<br/>    }))<br/>    enable_dns_support   = optional(bool, true)<br/>    enable_dns_hostnames = optional(bool, true)<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | n/a |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | n/a |
| <a name="output_full_name"></a> [full\_name](#output\_full\_name) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_intra_vpc_security_group_id"></a> [intra\_vpc\_security\_group\_id](#output\_intra\_vpc\_security\_group\_id) | n/a |
| <a name="output_ipv6_network_cidr"></a> [ipv6\_network\_cidr](#output\_ipv6\_network\_cidr) | n/a |
| <a name="output_ipv6_secondary_cidrs"></a> [ipv6\_secondary\_cidrs](#output\_ipv6\_secondary\_cidrs) | n/a |
| <a name="output_isolated_ipv6_subnet_cidrs"></a> [isolated\_ipv6\_subnet\_cidrs](#output\_isolated\_ipv6\_subnet\_cidrs) | n/a |
| <a name="output_isolated_route_table_ids"></a> [isolated\_route\_table\_ids](#output\_isolated\_route\_table\_ids) | n/a |
| <a name="output_isolated_subnet_cidrs"></a> [isolated\_subnet\_cidrs](#output\_isolated\_subnet\_cidrs) | n/a |
| <a name="output_isolated_subnet_name_to_subnet_id"></a> [isolated\_subnet\_name\_to\_subnet\_id](#output\_isolated\_subnet\_name\_to\_subnet\_id) | n/a |
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
