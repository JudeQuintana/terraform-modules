# Generate Routes to Other VPCs Description

See Building a generate routes function using Terraform test blog post.

This is a function type module (no resources) that will take a map of `tiered_vpc_ng` objects.

It will output a map of routes to other VPCs to be consumed by route resources.

The `call` output is `{ "rtb-id|route" => "route", ... }`.

Run `terraform test` in the `./utils/generate_routes_to_other_vpcs` directory to vaidate the test suite.

The test suite will help when refactoring is needed.

Example future use in TGW Centralized Router:
```
# snippet
module "generate_routes_to_other_vpcs" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//utils/generate_routes_to_other_vpcs"

  vpcs = var.vpcs
}

resource "aws_route" "this" {
  for_each = module.generate_routes_to_other_vpcs.call

  destination_cidr_block = each.value
  route_table_id         = split("|", each.key)[0]
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
}
```


## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.4 |

## Providers

| Name | Version |
|------|---------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpcs | map of tiered\_vpc\_ng objects | <pre>map(object({<br>    network                      = string<br>    az_to_private_route_table_id = map(string)<br>    az_to_public_route_table_id  = map(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| call | n/a |
