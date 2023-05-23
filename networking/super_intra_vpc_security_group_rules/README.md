# Super Intra VPC Secuity Group Rules Description
- This allowing inbound protocols across regions based on rules (ie ssh, icmp, etc) that
  were used in each intra\_vpc\_security\_group\_rules modules for all vpcs in each region.
- Rule sets for local and peer should be the same. also enforce by validation

- See [security\_group\_rules.tf](https://github.com/JudeQuintana/terraform-main/blob/main/super_router_demo/security_group_rules.tf) in the [Super Router Demo](https://github.com/JudeQuintana/terraform-main/tree/main/super_router_demo).

Example:
```
module "super_intra_vpc_security_group_rules_usw2_to_use1" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/super_intra_vpc_security_group_rules?ref=v1.4.18"

  providers = {
    aws.local = aws.usw2
    aws.peer  = aws.use1
  }

  env_prefix       = var.env_prefix
  region_az_labels = var.region_az_labels
  super_intra_vpc_security_group_rules = {
    local = {
      intra_vpc_security_group_rules = module.intra_vpc_security_group_rules_usw2
    }
    peer = {
      intra_vpc_security_group_rules = module.intra_vpc_security_group_rules_use1
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
| <a name="provider_aws.local"></a> [aws.local](#provider\_aws.local) | >=4.20 |
| <a name="provider_aws.peer"></a> [aws.peer](#provider\_aws.peer) | >=4.20 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group_rule.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_region_az_labels"></a> [region\_az\_labels](#input\_region\_az\_labels) | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |
| <a name="input_super_intra_vpc_security_group_rules"></a> [super\_intra\_vpc\_security\_group\_rules](#input\_super\_intra\_vpc\_security\_group\_rules) | super intra vpc security group rules configuration | <pre>object({<br>    # security rule object to allow inbound across vpcs intra-vpc security group<br>    local = object({<br>      intra_vpc_security_group_rules = map(object({<br>        account_id = string<br>        region     = string<br>        rule = object({<br>          label     = string<br>          protocol  = string<br>          from_port = number<br>          to_port   = number<br>        })<br>        vpcs = map(object({<br>          id                          = string<br>          intra_vpc_security_group_id = string<br>          network_cidr                = string<br>        }))<br>    })) })<br>    peer = object({<br>      intra_vpc_security_group_rules = map(object({<br>        account_id = string<br>        region     = string<br>        rule = object({<br>          label     = string<br>          protocol  = string<br>          from_port = number<br>          to_port   = number<br>        })<br>        vpcs = map(object({<br>          id                          = string<br>          intra_vpc_security_group_id = string<br>          network_cidr                = string<br>        }))<br>    })) })<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_local"></a> [local](#output\_local) | n/a |
| <a name="output_peer"></a> [peer](#output\_peer) | n/a |
