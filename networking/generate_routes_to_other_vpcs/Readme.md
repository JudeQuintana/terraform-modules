# Generate Routes to Other VPCs

Scope-agnostic route compilation unit that evaluates a routing policy
(deny > allow > segments > default) to generate IPv4 and IPv6 VPC route objects.

This is a function-type module (no resources). It takes a map of Tiered VPC-NG objects
and an optional `routing_policy`, then emits filtered route sets consumed by route resources
in Centralized Router (Regional IR), Full Mesh Trio (Global IR), and Super Router (Domain IR).

Run the test suites with `terraform init`, then `terraform test` in the top level directory in the repo.
```
...
Success! 103 passed, 0 failed.
```
`v1.11.0`
- Compiler toolchain inspection (`reachability`, `diagnostics`, `provenance`, `policy_diff`, `equivalence`) now passed
  directly in the `generate_routes_to_other_vpcs` input object from the calling IR module's `inspect` field.
- See [docs/compiler-toolchain.md](docs/compiler-toolchain.md) for updated inspection interface.
- See [docs/routing-policy-language.md](docs/routing-policy-language.md) for full specification.

`v1.10.0`
- Routing policy language integration.
- Policy algebra with four primitives and fixed precedence: deny > allow > segments > default.
- Dual-stack support: one policy declaration controls both IPv4 and IPv6 route generation.
- Scope-invariant: same evaluation across Regional IR (Centralized Router), Global IR (Full Mesh Trio), and Domain IR (Super Router).
- 51 new policy tests (deny, segments, precedence) added to existing 15 route generation tests.
- See [docs/routing-policy-language.md](docs/routing-policy-language.md) for full specification.

```hcl
# snippet
module "generate_routes_to_other_vpcs" {
 source = "git@github.com:JudeQuintana/terraform-modules.git//networking/generate_routes_to_other_vpcs?ref=v1.10.0"

  routing_policy = var.routing_policy
  vpcs           = var.vpcs
}
```

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
| <a name="input_generate_routes_to_other_vpcs"></a> [generate\_routes\_to\_other\_vpcs](#input\_generate\_routes\_to\_other\_vpcs) | Configuration for scope-agnostic route compilation: VPCs, routing policy, and optional inspect inputs. | <pre>object({<br/>    vpcs = map(object({<br/>      network_cidr            = string<br/>      secondary_cidrs         = optional(list(string), [])<br/>      ipv6_network_cidr       = optional(string)<br/>      ipv6_secondary_cidrs    = optional(list(string), [])<br/>      private_route_table_ids = list(string)<br/>      public_route_table_ids  = list(string)<br/>    }))<br/>    routing_policy = object({<br/>      default = string<br/>      deny = optional(list(object({<br/>        from = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>        to = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>      })), [])<br/>      allow = optional(list(object({<br/>        from = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>        to = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>      })), [])<br/>      segments = optional(map(list(object({<br/>        network_cidr         = string<br/>        secondary_cidrs      = optional(list(string), [])<br/>        ipv6_network_cidr    = optional(string)<br/>        ipv6_secondary_cidrs = optional(list(string), [])<br/>      }))), {})<br/>    })<br/>    previous_reachability = optional(map(string))<br/>    equivalent_routing_policy = optional(object({<br/>      default = string<br/>      deny = optional(list(object({<br/>        from = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>        to = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>      })), [])<br/>      allow = optional(list(object({<br/>        from = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>        to = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>      })), [])<br/>      segments = optional(map(list(object({<br/>        network_cidr         = string<br/>        secondary_cidrs      = optional(list(string), [])<br/>        ipv6_network_cidr    = optional(string)<br/>        ipv6_secondary_cidrs = optional(list(string), [])<br/>      }))), {})<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_diagnostics"></a> [diagnostics](#output\_diagnostics) | n/a |
| <a name="output_equivalence"></a> [equivalence](#output\_equivalence) | n/a |
| <a name="output_ipv4"></a> [ipv4](#output\_ipv4) | output routes as set of objects instead of a map it makes it easier to handle when passing to other route resource types (vpc, tgw) toset([{ route\_table\_id = "rtb-12345678", destination\_cidr\_block = "x.x.x.x/x" }, ...]) |
| <a name="output_ipv6"></a> [ipv6](#output\_ipv6) | n/a |
| <a name="output_policy_diff"></a> [policy\_diff](#output\_policy\_diff) | n/a |
| <a name="output_provenance"></a> [provenance](#output\_provenance) | n/a |
| <a name="output_reachability"></a> [reachability](#output\_reachability) | n/a |
