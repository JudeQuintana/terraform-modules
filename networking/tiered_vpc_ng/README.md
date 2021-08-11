# Coming Soon
Terraform Networking Trifecta Blog Post + Demo

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
