# Generate Routes to Other VPCs Description

`v1.8.2`
- now supports genearating routes IPv4 Secondary cidrs and IPv6 cidrs across vpcs

Run the test suites with `terraform test` in the `./modules/generate_routes_to_other_vpcs` directory.
```
tests/generate_routes.tftest.hcl... in progress
  run "setup"... pass
  run "final"... pass
  run "ipv4_call_with_n_greater_than_one"... pass
  run "ipv4_call_with_n_equal_to_one"... pass
  run "ipv4_call_with_n_equal_to_zero"... pass
  run "ipv4_cidr_validation"... pass
  run "ipv4_with_secondary_cidrs_call_with_n_greater_than_one"... pass
  run "ipv4_with_secondary_cidrs_call_with_n_equal_to_one"... pass
  run "ipv4_with_secondary_cidrs_call_with_n_equal_to_zero"... pass
  run "ipv6_call_with_n_greater_than_one"... pass
  run "ipv6_call_with_n_equal_to_one"... pass
  run "ipv6_with_secondary_cidrs_call_with_n_equal_to_zero"... pass
tests/generate_routes.tftest.hcl... tearing down
tests/generate_routes.tftest.hcl... pass

Success! 12 passed, 0 failed.
```

`v1.8.1`
This is a function type module (no resources) that will take a map of `tiered_vpc_ng` objects with [Tiered VPC-NG](https://github.com/JudeQuintana/terraform-modules/tree/master/networking/tiered_vpc_ng).

It will create a map of routes to other VPC networks (execept itself) which will then be consumed by route resources.

The `call` output is `toset([{ route_table_id = "rtb-12345678", destination_cidr_block = "x.x.x.x/x" }, ...])`.

A list of route objects makes it easier to handle when passing to other route resource types (ie vpc, tgw) than a map of routes.

```hcl
# snippet
module "generate_routes_to_other_vpcs" {
  source = "./modules/generate_routes_to_other_vpcs"

  vpcs = var.vpcs
}

locals {
  vpc_routes_to_other_vpcs = {
    for this in module.generate_routes_to_other_vpcs.call :
    format("|", this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this" {
  for_each = local.vpc_routes_to_other_vpcs

  destination_cidr_block = each.value.destination_cidr_block
  route_table_id         = each.value.route_table_id
  transit_gateway_id     = aws_ec2_transit_gateway.this.id

  # make sure the tgw route table is available first before the setting routes routes on the vpcs
  depends_on = [aws_ec2_transit_gateway_route_table.this]
}
```

Run the test suites with `terraform test` in the `./modules/generate_routes_to_other_vpcs` directory.
```
tests/generate_routes.tftest.hcl... in progress
  run "setup"... pass
  run "final"... pass
  run "call_with_n_greater_than_one"... pass
  run "call_with_n_equal_to_one"... pass
  run "call_with_n_equal_to_zero"... pass
  run "cidr_validation"... pass
tests/generate_routes.tftest.hcl... tearing down
tests/generate_routes.tftest.hcl... pass
```

The test suite will help when refactoring is needed.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | map of tiered\_vpc\_ng objects | <pre>map(object({<br>    network_cidr            = string<br>    secondary_cidrs         = optional(list(string), [])<br>    ipv6_network_cidr       = optional(string)<br>    private_route_table_ids = list(string)<br>    public_route_table_ids  = list(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ipv4"></a> [ipv4](#output\_ipv4) | output routes as set of objects instead of a map it makes it easier to handle when passing to other route resource types (vpc, tgw) toset([{ route\_table\_id = "rtb-12345678", destination\_cidr\_block = "x.x.x.x/x" }, ...]) |
| <a name="output_ipv6"></a> [ipv6](#output\_ipv6) | n/a |
