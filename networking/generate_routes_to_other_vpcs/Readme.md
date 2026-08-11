# Generate Routes to Other VPCs

Scope-agnostic route compilation unit that evaluates a routing policy
(deny > allow > segments > default) to generate IPv4 and IPv6 VPC route objects.

This is a function-type module (no resources). It takes a map of Tiered VPC-NG objects
and an optional `routing_policy`, then emits filtered route sets consumed by route resources
in Centralized Router (Regional IR), Full Mesh Trio (Global IR), and Super Router (Domain IR).

Run the test suites with `terraform test` in the top level directory in the repo.
```
```
tests/deny\_policy.tftest.hcl... in progress
  run "setup"... pass
  run "final\_deny"... pass
  run "ipv4\_deny\_app\_to\_cicd"... pass
  run "ipv4\_with\_secondary\_cidrs\_deny\_app\_to\_cicd"... pass
  run "ipv4\_deny\_all\_pairs"... pass
  run "ipv4\_with\_secondary\_cidrs\_deny\_all\_pairs"... pass
  run "final"... pass
  run "ipv4\_empty\_deny\_unchanged"... pass
  run "ipv4\_default\_policy\_unchanged"... pass
  run "ipv6\_deny\_app\_to\_cicd"... pass
  run "ipv6\_with\_secondary\_cidrs\_deny\_app\_to\_cicd"... pass
  run "ipv6\_deny\_all\_pairs"... pass
  run "ipv6\_empty\_deny\_unchanged"... pass
  run "ipv6\_default\_policy\_unchanged"... pass
tests/deny\_policy.tftest.hcl... tearing down
tests/deny\_policy.tftest.hcl... pass
tests/generate\_routes.tftest.hcl... in progress
  run "setup"... pass
  run "final"... pass
  run "ipv4\_call\_with\_n\_greater\_than\_one"... pass
  run "ipv4\_call\_with\_n\_equal\_to\_one"... pass
  run "ipv4\_call\_with\_n\_equal\_to\_zero"... pass
  run "ipv4\_cidr\_validation"... pass
  run "ipv4\_with\_secondary\_cidrs\_call\_with\_n\_greater\_than\_one"... pass
  run "ipv4\_with\_secondary\_cidrs\_call\_with\_n\_equal\_to\_one"... pass
  run "ipv4\_with\_secondary\_cidrs\_call\_with\_n\_equal\_to\_zero"... pass
  run "ipv6\_call\_with\_n\_greater\_than\_one"... pass
  run "ipv6\_call\_with\_n\_equal\_to\_one"... pass
  run "ipv6\_call\_with\_n\_equal\_to\_zero"... pass
  run "ipv6\_call\_with\_ipv6\_secondary\_cidrs\_with\_n\_greater\_than\_zero"... pass
  run "ipv6\_with\_secondary\_cidrs\_call\_with\_n\_equal\_to\_one"... pass
  run "ipv6\_with\_ipv6\_secondary\_cidrs\_call\_with\_n\_equal\_to\_zero"... pass
tests/generate\_routes.tftest.hcl... tearing down
tests/generate\_routes.tftest.hcl... pass
tests/precedence\_policy.tftest.hcl... in progress
  run "setup"... pass
  run "final\_precedence"... pass
  run "final\_deny"... pass
  run "final"... pass
  run "ipv4\_default\_deny\_no\_rules"... pass
  run "ipv4\_default\_deny\_allow\_app\_cicd"... pass
  run "ipv4\_default\_deny\_segment\_workers"... pass
  run "ipv4\_deny\_beats\_allow"... pass
  run "ipv4\_allow\_overrides\_segments"... pass
  run "ipv4\_with\_secondary\_cidrs\_default\_deny\_allow\_app\_cicd"... pass
  run "ipv4\_with\_secondary\_cidrs\_default\_deny\_segment\_workers"... pass
  run "ipv4\_with\_secondary\_cidrs\_deny\_beats\_allow"... pass
  run "ipv4\_with\_secondary\_cidrs\_allow\_overrides\_segments"... pass
  run "ipv4\_combined\_precedence"... pass
  run "ipv4\_with\_secondary\_cidrs\_combined\_precedence"... pass
  run "ipv4\_default\_allow\_empty\_policy"... pass
  run "ipv6\_default\_deny\_no\_rules"... pass
  run "ipv6\_default\_deny\_allow\_app\_cicd"... pass
  run "ipv6\_default\_deny\_segment\_workers"... pass
  run "ipv6\_deny\_beats\_allow"... pass
  run "ipv6\_allow\_overrides\_segments"... pass
  run "ipv6\_combined\_precedence"... pass
  run "ipv6\_default\_allow\_empty\_policy"... pass
tests/precedence\_policy.tftest.hcl... tearing down
tests/precedence\_policy.tftest.hcl... pass
tests/segments\_policy.tftest.hcl... in progress
  run "setup"... pass
  run "final\_segments"... pass
  run "final"... pass
  run "ipv4\_one\_segment\_general\_unsegmented"... pass
  run "ipv4\_two\_segments\_general\_unsegmented"... pass
  run "ipv4\_all\_separate\_segments"... pass
  run "ipv4\_with\_secondary\_cidrs\_two\_segments\_general\_unsegmented"... pass
  run "ipv4\_with\_secondary\_cidrs\_all\_separate\_segments"... pass
  run "ipv4\_empty\_segments\_unchanged"... pass
  run "ipv4\_vpc\_in\_multiple\_segments"... pass
  run "ipv6\_two\_segments\_general\_unsegmented"... pass
  run "ipv6\_all\_separate\_segments"... pass
  run "ipv6\_with\_secondary\_cidrs\_two\_segments\_general\_unsegmented"... pass
  run "ipv6\_empty\_segments\_unchanged"... pass
tests/segments\_policy.tftest.hcl... tearing down
tests/segments\_policy.tftest.hcl... pass

Success! 66 passed, 0 failed.
 The test suite will help when refactoring is needed.

`v1.10.0`
- Routing policy language integration.
- Policy algebra with four primitives and fixed precedence: deny > allow > segments > default.
- Dual-stack support: one policy declaration controls both IPv4 and IPv6 route generation.
- Scope-invariant: same evaluation across Regional IR (Centralized Router), Global IR (Full Mesh Trio), and Domain IR (Super Router).
- 51 new policy tests (deny, segments, precedence) added to existing 15 route generation tests.
- See [docs/routing-policy-language.md](docs/routing-policy-language.md) for full specification.

`v1.9.0`
- supportes generating VPC routes for IPv6 secondary cidrs across vpcs.

`v1.8.2`
- now supports generating VPC routes IPv4 Secondary cidrs and IPv6 cidrs across vpcs.

`v1.8.1`
This is a function type module (no resources) that will take a map of `tiered_vpc_ng` objects with [Tiered VPC-NG](https://github.com/JudeQuintana/terraform-modules/tree/master/networking/tiered_vpc_ng).

It will create a map of routes to other VPC networks (execept itself) which will then be consumed by route resources.

The `call` output is `toset([{ route_table_id = "rtb-12345678", destination_cidr_block = "x.x.x.x/x" }, ...])`.

A list of route objects makes it easier to handle when passing to other route resource types (ie vpc, tgw) than a map of routes.

```hcl
# snippet
module "generate_routes_to_other_vpcs" {
 source = "git@github.com:JudeQuintana/terraform-modules.git//networking/generate_routes_to_other_vpcs?ref=v1.8.1"

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

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_routing_policy"></a> [routing\_policy](#input\_routing\_policy) | routing policy constraints | <pre>object({<br/>    default = optional(string, "allow")<br/>    deny = optional(list(object({<br/>      from = object({<br/>        network_cidr         = string<br/>        secondary_cidrs      = optional(list(string), [])<br/>        ipv6_network_cidr    = optional(string)<br/>        ipv6_secondary_cidrs = optional(list(string), [])<br/>      })<br/>      to = object({<br/>        network_cidr         = string<br/>        secondary_cidrs      = optional(list(string), [])<br/>        ipv6_network_cidr    = optional(string)<br/>        ipv6_secondary_cidrs = optional(list(string), [])<br/>      })<br/>    })), [])<br/>    allow = optional(list(object({<br/>      from = object({<br/>        network_cidr         = string<br/>        secondary_cidrs      = optional(list(string), [])<br/>        ipv6_network_cidr    = optional(string)<br/>        ipv6_secondary_cidrs = optional(list(string), [])<br/>      })<br/>      to = object({<br/>        network_cidr         = string<br/>        secondary_cidrs      = optional(list(string), [])<br/>        ipv6_network_cidr    = optional(string)<br/>        ipv6_secondary_cidrs = optional(list(string), [])<br/>      })<br/>    })), [])<br/>    segments = optional(map(list(object({<br/>      network_cidr         = string<br/>      secondary_cidrs      = optional(list(string), [])<br/>      ipv6_network_cidr    = optional(string)<br/>      ipv6_secondary_cidrs = optional(list(string), [])<br/>    }))), {})<br/>  })</pre> | `{}` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | map of tiered\_vpc\_ng objects | <pre>map(object({<br/>    network_cidr            = string<br/>    secondary_cidrs         = optional(list(string), [])<br/>    ipv6_network_cidr       = optional(string)<br/>    ipv6_secondary_cidrs    = optional(list(string), [])<br/>    private_route_table_ids = list(string)<br/>    public_route_table_ids  = list(string)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_ipv4"></a> [ipv4](#output\_ipv4) | output routes as set of objects instead of a map it makes it easier to handle when passing to other route resource types (vpc, tgw) toset([{ route\_table\_id = "rtb-12345678", destination\_cidr\_block = "x.x.x.x/x" }, ...]) |
| <a name="output_ipv6"></a> [ipv6](#output\_ipv6) | n/a |
