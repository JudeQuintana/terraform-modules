# Coming Soon
Terraform Networking Trifecta Blog Post + Demo

# Description
This Intra VPC Security Group Rule will create a SG Rule for each Tiered VPC allowing inbound-only ports from all other VPC networks (excluding itself).

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
| env\_prefix | prod, stage, etc | `string` | n/a | yes |
| rule | security rule object to allow inbound across vpcs intra-vpc security group | <pre>object({<br>    label     = string<br>    from_port = number<br>    to_port   = number<br>    protocol  = string<br>  })</pre> | n/a | yes |
| vpcs | map of tiered\_vpc\_ng objects | <pre>map(object({<br>    id                          = string<br>    network                     = string<br>    intra_vpc_security_group_id = string<br>  }))</pre> | n/a | yes |

## Outputs

No output.
