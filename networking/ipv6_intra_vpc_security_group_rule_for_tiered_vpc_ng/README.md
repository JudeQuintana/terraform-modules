# IPv6 Intra VPC Security Group Rule Description
This IPv6 Intra VPC Security Group Rule will create a SG Rule for each Tiered VPC allowing inbound-only ports from all other VPC networks (excluding itself).

`v1.9.0`
- support for ipv6 secondary cidrs
- moar validation
```
module "ipv6_intra_vpc_security_group_rules" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/ipv6_intra_vpc_security_group_rule_for_tiered_vpc_ng?ref=1.9.0"
..
```

`v1.8.2`
- New [Dual Stack Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/dual_stack_networking_trifecta_demo)
- Similar declaration to Intra VPC Security Group Rules modules but this only supports IPv6
- important to keep IPv6 SG rules as a separate module from IPv4

`v1.8.2` example:
```

locals {
  ipv6_intra_vpc_security_group_rules = [
    {
      label     = "ssh6"
      protocol  = "tcp"
      from_port = 22
      to_port   = 22
    },
    {
      label     = "ping6"
      protocol  = "icmpv6"
      from_port = -1
      to_port   = -1
    }
  ]
}

# Allowing IPv6 SSH and ping communication across all VPCs
module "ipv6_intra_vpc_security_group_rules" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/ipv6_intra_vpc_security_group_rule_for_tiered_vpc_ng?ref=1.8.2"

  for_each = { for r in local.ipv6_intra_vpc_security_group_rules : r.label => r }

  env_prefix       = var.env_prefix
  region_az_labels = var.region_az_labels
  ipv6_intra_vpc_security_group_rule = {
    rule = each.value
    vpcs = module.vpcs
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3 |
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
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_ipv6_intra_vpc_security_group_rule"></a> [ipv6\_intra\_vpc\_security\_group\_rule](#input\_ipv6\_intra\_vpc\_security\_group\_rule) | intra vpc security group rule configuration | <pre>object({<br/>    # security rule object to allow inbound across vpcs intra-vpc security group<br/>    rule = object({<br/>      label     = string<br/>      protocol  = string<br/>      from_port = number<br/>      to_port   = number<br/>    })<br/>    # map of tiered_vpc_ng objects<br/>    vpcs = map(object({<br/>      id                          = string<br/>      intra_vpc_security_group_id = string<br/>      name                        = string<br/>      ipv6_network_cidr           = string<br/>      ipv6_secondary_cidrs        = list(string)<br/>      region                      = string<br/>      account_id                  = string<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_region_az_labels"></a> [region\_az\_labels](#input\_region\_az\_labels) | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
| <a name="output_rule"></a> [rule](#output\_rule) | n/a |
| <a name="output_vpcs"></a> [vpcs](#output\_vpcs) | n/a |
