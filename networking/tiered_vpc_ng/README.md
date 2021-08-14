## Networking Trifecta Demo
Blog Post:
[Terraform Networking Trifecta ](https://jq1.io/posts/tnt/)

Main:
- [Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/networking_trifecta_demo)
  - See [Trifecta Demo Time](/posts/tnt/#trifecta-demo-time) for instructions.

# Description
Baseline Tiered VPC-NG features (same as prototype):

- Create VPC tiers
  - It’s much easier to think about tiers when scaling out VPCs because we can narrow down the context (ie app, db, general) and maximize the use of smaller network size when needed.

- VPC resources are IPv4 only.
  - No IPv6 configuration for now.

- Creates structured VPC resource naming and tagging.
  - `<env_prefix>-<region|az>-<tier_name>-<public|private>-<pet_name|misc_label>`

- Requires a minimum of at least one public subnet per AZ.

- Can add and remove subnets and/or AZs at any time*

- Internal and external VPC routing is automatic.

Whats new in NG?

- An Intra VPC Security Group is created by default.
  - This will be for adding security group rules that are inbound only
    for access across VPCs.

- No more nulling out private subnets ie `private = null`.
  - Just populate the list to create them ie `private = []` just like
  the public subnets.

- NAT Gateways are no longer built by default when private subnets exist in an AZ.
  - This allows for routable private subnets that have no outbound internet traffic unless `enable_natgw = true`, in which case the NAT Gateway will be built and private route tables updated.
  - Now you can just "flip the switch" to give all private
 subnets in an AZ access to the internet.
  - NAT Gateways are created with an EIP per AZ when enabled.
    - This is why we need at least one public subnet per AZ to create them in.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.4 |
| aws | ~> 3.53.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.53.0 |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| env\_prefix | prod, stage, etc | `string` | n/a | yes |
| region\_az\_labels | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |
| tier | n/a | <pre>object({<br>    name    = string<br>    network = string<br>    azs = map(object({<br>      enable_natgw = optional(bool)<br>      public       = list(string)<br>      private      = list(string)<br>    }))<br>  })</pre> | n/a | yes |
| tags | Additional Tags | `map(string)` | `{}` | no |
| tenancy | Set VPC Tenancy | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| default\_security\_group\_id | n/a |
| id | n/a |
| intra\_vpc\_security\_group\_id | n/a |
| network | n/a |
| az\_to\_private\_subnet\_ids | n/a |
| az\_to\_private\_route\_table\_id | n/a |
| az\_to\_public\_subnet\_ids | n/a |
| az\_to\_public\_route\_table\_id | n/a |
