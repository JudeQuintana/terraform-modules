
Idea: Ultra CloudWAN for Super Router

Super Router provides scalable cross-region peering and routing between tgws and vpcs (no dx or vpn).
![super-router-base-architecture](https://jq1-io.s3.amazonaws.com/super-router/super-router-architecture.png)

I was was thinking about building a cloudwan module to connect several super routers togther but only go thru cloudwan if the destination region is not one of the super router’s tgw pair (ie. us-west-2 <=> eu-central-1):
![ultra-cloudwan-init](https://jq1-io.s3.amazonaws.com/ultra-cloudwan/ultra-cloudwan-init.png)

*/

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.67 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.67 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region_az_labels"></a> [region\_az\_labels](#input\_region\_az\_labels) | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional Tags | `map(string)` | `{}` | no |
| <a name="input_ultra_cloudwan"></a> [ultra\_cloudwan](#input\_ultra\_cloudwan) | ultra cloudwan configuration. | <pre>object({<br>    name = string<br>    super_routers = map(object({<br>      local = object({<br>        account_id      = string<br>        amazon_side_asn = string<br>        full_name       = string<br>        id              = string<br>        network_cidrs   = string<br>        region          = string<br>        route_table_id  = string<br>      })<br>      peer = object({<br>        account_id      = string<br>        amazon_side_asn = string<br>        full_name       = string<br>        id              = string<br>        network_cidrs   = string<br>        region          = string<br>        route_table_id  = string<br>      })<br>    }))<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
