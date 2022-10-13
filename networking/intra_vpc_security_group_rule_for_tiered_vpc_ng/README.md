# Networking Trifecta Demo
Blog Post:
[Terraform Networking Trifecta ](https://jq1.io/posts/tnt/)

Main:
- [Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/networking_trifecta_demo)
  - See [Trifecta Demo Time](https://jq1.io/posts/tnt/#trifecta-demo-time) for instructions.

# Intra VPC Security Group Rule Description
This Intra VPC Security Group Rule will create a SG Rule for each Tiered VPC allowing inbound-only ports from all other VPC networks (excluding itself).

Example:
```
locals {
  intra_vpcs_security_group_rules = [
    {
      label     = "ssh"
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
    },
    {
      label     = "ping"
      from_port = 8
      to_port   = 0
      protocol  = "icmp"
    }
  ]
}

module "intra_vpc_security_group_rules" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/intra_vpc_security_group_rule_for_tiered_vpc_ng?ref=v1.4.5"

  for_each = { for r in local.intra_vpcs_security_group_rules : r.label => r }

  env_prefix = var.env_prefix
  vpcs       = module.vpcs
  rule       = each.value
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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_rule"></a> [rule](#input\_rule) | security rule object to allow inbound across vpcs intra-vpc security group | <pre>object({<br>    label     = string<br>    from_port = number<br>    to_port   = number<br>    protocol  = string<br>  })</pre> | n/a | yes |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | map of tiered\_vpc\_ng objects | <pre>map(object({<br>    id                          = string<br>    network                     = string<br>    intra_vpc_security_group_id = string<br>  }))</pre> | n/a | yes |

## Outputs

No outputs.
