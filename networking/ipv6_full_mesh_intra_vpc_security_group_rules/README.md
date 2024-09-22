# Full Mesh Intra VPC Secuity Group Rules Description
- This allowing inbound protocols across regions based on rules (ie ssh, icmp, etc) that
  were used in each intra\_vpc\_security\_group\_rules modules for all vpcs in each region while in a TGW full mesh configuration.
- Rule sets for one, two and three Intra VPC Security Group Rules should be the same. also enforced by validation
- See it in action in [security\_group\_rules.tf](https://github.com/JudeQuintana/terraform-main/blob/main/full_mesh_trio_demo/security_group_rules.tf) in the [Full Mesh Trio Demo](https://github.com/JudeQuintana/terraform-main/tree/main/full_mesh_trio_demo).

```
module "full_mesh_intra_vpc_security_groups_rules" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/full_mesh_intra_vpc_security_group_rules?ref=v1.7.5"

  providers = {
    aws.one   = aws.use1
    aws.two   = aws.use2
    aws.three = aws.usw2
  }

  env_prefix       = var.env_prefix
  region_az_labels = var.region_az_labels
  full_mesh_intra_vpc_security_group_rules = {
    one = {
      intra_vpc_security_group_rules = module.intra_vpc_security_group_rules_use1
    }
    two = {
      intra_vpc_security_group_rules = module.intra_vpc_security_group_rules_use2
    }
    three = {
      intra_vpc_security_group_rules = module.intra_vpc_security_group_rules_usw2
    }
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
| <a name="provider_aws.one"></a> [aws.one](#provider\_aws.one) | >=4.20 |
| <a name="provider_aws.three"></a> [aws.three](#provider\_aws.three) | >=4.20 |
| <a name="provider_aws.two"></a> [aws.two](#provider\_aws.two) | >=4.20 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group_rule.this_one_to_this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.this_one_to_this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.this_three_to_this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.this_three_to_this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.this_two_to_this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.this_two_to_this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_ipv6_full_mesh_intra_vpc_security_group_rules"></a> [ipv6\_full\_mesh\_intra\_vpc\_security\_group\_rules](#input\_ipv6\_full\_mesh\_intra\_vpc\_security\_group\_rules) | IPv6 full mesh intra vpc security group rules configuration | <pre>object({<br>    # security rule object to allow inbound across vpcs intra-vpc security group<br>    one = object({<br>      ipv6_intra_vpc_security_group_rules = map(object({<br>        account_id = string<br>        region     = string<br>        rule = object({<br>          label     = string<br>          protocol  = string<br>          from_port = number<br>          to_port   = number<br>        })<br>        vpcs = map(object({<br>          id                          = string<br>          intra_vpc_security_group_id = string<br>          ipv6_network_cidr           = string<br>        }))<br>    })) })<br>    two = object({<br>      ipv6_intra_vpc_security_group_rules = map(object({<br>        account_id = string<br>        region     = string<br>        rule = object({<br>          label     = string<br>          protocol  = string<br>          from_port = number<br>          to_port   = number<br>        })<br>        vpcs = map(object({<br>          id                          = string<br>          intra_vpc_security_group_id = string<br>          ipv6_network_cidr           = string<br>        }))<br>    })) })<br>    three = object({<br>      ipv6_intra_vpc_security_group_rules = map(object({<br>        account_id = string<br>        region     = string<br>        rule = object({<br>          label     = string<br>          protocol  = string<br>          from_port = number<br>          to_port   = number<br>        })<br>        vpcs = map(object({<br>          id                          = string<br>          intra_vpc_security_group_id = string<br>          ipv6_network_cidr           = string<br>        }))<br>    })) })<br>  })</pre> | n/a | yes |
| <a name="input_region_az_labels"></a> [region\_az\_labels](#input\_region\_az\_labels) | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_one"></a> [one](#output\_one) | n/a |
| <a name="output_three"></a> [three](#output\_three) | n/a |
| <a name="output_two"></a> [two](#output\_two) | n/a |
