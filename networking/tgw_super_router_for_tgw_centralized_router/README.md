# Super Router

Decentralized cross-region peering between two sets of Centralized Routers.
Builds a dedicated TGW pair (local and peer) with peering attachments and
static routes, then compiles an optional routing policy (deny > allow > segments > default)
into cross-region VPC route table entries. Operates as the Domain IR, evaluating
policy across an arbitrary number of Centralized Routers on each side.

v1.12.0:
- Five new inspect toggles: `assertions`, `blast_radius`, `segment_report`, `policy_normalization`, `connectivity_graph`.
- Boolean-gated outputs for `segment_report`, `policy_normalization`, and `connectivity_graph`.
- Input-gated outputs for `assertions` (object with `must_deny`/`must_permit`) and `blast_radius` (derived from `policy_diff`).
- Connectivity graph writes a `.dot` file (raw DOT, not JSON).
- Uses `generate_routes_to_other_vpcs` v1.12.0.

v1.11.0:
- Breaking change: `routing_policy` is now required (no default). Matches Centralized Router interface.
- New `inspect` field nested inside `var.super_router.inspect` for compiler semantic toolchain outputs.
- Three validations for `routing_policy`: default must be allow or deny, segment uniqueness
  with inline duplicate CIDRs, out-of-scope CIDRs with inline error.
- Three validations for `equivalent_routing_policy` with cross-field validation against in-scope VPCs.
- New `inspect.tf` for reachability, diagnostics, provenance, policy\_diff, and equivalence outputs.

v1.10.0:
- Breaking change: cross-region VPC routes now use policy compilation instead of VPC aggregate setproduct.
- Route resource names are consolidated and renamed.
- New `routing_policy` variable with four primitives and fixed precedence: deny > allow > segments > default.
- Dual-stack support: one policy declaration controls both IPv4 and IPv6 route generation.
- Scope-invariant: same policy evaluation as Centralized Router and Full Mesh Trio.
- Uses `generate_routes_to_other_vpcs` v1.10.0 as the shared compilation unit.

v1.9.6 (v1.0.1):
Super Router now fully interprets AWS TGW network intent across address space, topology, and egress semantics, with no special cases.

What's new
- Full support for IPv4 and IPv6, including primary and secondary CIDRs
- Ability to define blackhole CIDRs on either side of Super Router
- Operates on semantic facts (CIDRs × route table identities) rather than emitted route artifacts
- Compatible with Centralized Router v1.0.6

Semantic Coverage

Super Router now provides complete semantic coverage of the AWS TGW routing domain:
- Expressive: handles all CIDR and address-family combinations
- Compositional: hierarchical domains compose cleanly
- Complete: covers the full AWS TGW routing semantic space

Example:
```
# Super Router is composed of two TGWs, one in each region.
module "super_router_usw2_to_use1" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/tgw_super_router_for_tgw_centralized_router?ref=v1.9.6"

  providers = {
    aws.local = aws.usw2 # local super router tgw will be built in the aws.local provider region
    aws.peer  = aws.use1 # peer super router tgw will be built in the aws.peer provider region
  }

  env_prefix       = var.env_prefix
  region_az_labels = var.region_az_labels
  super_router = {
    name = "professor-x"
    local = {
      amazon_side_asn     = 64521
      blackhole           = local.blackhole
      centralized_routers = module.centralized_routers_usw2
    }
    peer = {
      amazon_side_asn     = 64522
      blackhole           = local.blackhole
      centralized_routers = module.centralized_routers_use1
    }
  }
}
```

The resulting architecture is a decentralized hub spoke topology:
![super-router-revamped](https://jq1-io.s3.amazonaws.com/super-router/super-router-revamped.png)

v1.7.5 (v1.0.0):
This is a follow up to the [generating routes post](https://jq1.io/posts/generating_routes/).

Original Blog Post: [Super Powered, Super Sharp, Super Router!](https://jq1.io/posts/super_router/)

Fresh new decentralized design in [$init super refactor](https://jq1.io/posts/init_super_refactor/).

New features means new steez in [Slappin chrome on the WIP'](https://jq1.io/posts/slappin_chrome_on_the_wip/)!

Super Router provides both intra-region and cross-region peering and routing for Centralized Routers and Tiered VPCs (same AWS account only, no cross account).

Super Router is composed of two TGWs instead of one TGW (one for each region).

Example:
```
module "super_router_usw2_to_use1" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/tgw_super_router_for_tgw_centralized_router?ref=v1.7.5"

  providers = {
    aws.local = aws.usw2 # local super router tgw will be built in the aws.local provider region
    aws.peer  = aws.use1 # peer super router tgw will be built in the aws.peer provider region
  }

  env_prefix       = var.env_prefix
  region_az_labels = var.region_az_labels
  super_router = {
    name = "professor-x"
    local = {
      amazon_side_asn     = 64521
      centralized_routers = module.centralized_routers_usw2
    }
    peer = {
      amazon_side_asn     = 64522
      centralized_routers = module.centralized_routers_use1
    }
  }
}
```

The resulting architecture is a decentralized hub spoke topology:
![super-router-shokunin](https://jq1-io.s3.amazonaws.com/super-router/super-router-shokunin.png)

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=4.20 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >=2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws.local"></a> [aws.local](#provider\_aws.local) | >=4.20 |
| <a name="provider_aws.peer"></a> [aws.peer](#provider\_aws.peer) | >=4.20 |
| <a name="provider_local"></a> [local](#provider\_local) | >=2.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_this_generate_routes_to_other_vpcs"></a> [this\_generate\_routes\_to\_other\_vpcs](#module\_this\_generate\_routes\_to\_other\_vpcs) | ../generate_routes_to_other_vpcs | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_ec2_transit_gateway.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_peering_attachment.this_local_to_locals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment.this_local_to_this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment.this_peer_to_peers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_peers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_route.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_local_blackholes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_local_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_local_ipv6_to_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_local_tgw_ipv6_routes_to_local_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_local_tgw_ipv6_routes_to_vpcs_in_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_local_tgw_routes_to_local_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_local_tgw_routes_to_vpcs_in_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_local_to_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_blackholes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_ipv6_to_local_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_tgw_ipv6_routes_to_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_tgw_ipv6_routes_to_vpcs_in_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_tgw_routes_to_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_tgw_routes_to_vpcs_in_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_peer_to_local_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_local_to_locals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_local_to_this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_peer_to_peers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_peer_to_this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_route.this_local_vpc_ipv6_routes_to_local_vpcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_local_vpc_ipv6_routes_to_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_local_vpc_routes_to_local_vpcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_local_vpc_routes_to_peer_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_peer_vpc_ipv6_routes_to_local_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_peer_vpc_ipv6_routes_to_peer_vpcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_peer_vpc_routes_to_local_tgws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_peer_vpc_routes_to_peer_vpcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [local_file.this_assertions](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.this_blast_radius](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.this_connectivity_graph](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.this_diagnostics](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.this_equivalence](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.this_policy_diff](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.this_policy_normalization](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.this_provenance](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.this_reachability](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.this_segment_report](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_caller_identity.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ec2_transit_gateway_peering_attachment.this_local_to_locals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_transit_gateway_peering_attachment) | data source |
| [aws_ec2_transit_gateway_peering_attachment.this_peer_to_peers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_transit_gateway_peering_attachment) | data source |
| [aws_region.this_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.this_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_region_az_labels"></a> [region\_az\_labels](#input\_region\_az\_labels) | Region and AZ names mapped to short naming conventions for labeling | `map(string)` | n/a | yes |
| <a name="input_super_router"></a> [super\_router](#input\_super\_router) | Super Router configuration | <pre>object({<br/>    name = string<br/>    routing_policy = object({<br/>      default = string<br/>      deny = optional(list(object({<br/>        from = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>        to = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>      })), [])<br/>      allow = optional(list(object({<br/>        from = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>        to = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>      })), [])<br/>      segments = optional(map(list(object({<br/>        network_cidr         = string<br/>        secondary_cidrs      = optional(list(string), [])<br/>        ipv6_network_cidr    = optional(string)<br/>        ipv6_secondary_cidrs = optional(list(string), [])<br/>      }))), {})<br/>    })<br/>    inspect = optional(object({<br/>      reachability = optional(bool, false)<br/>      diagnostics  = optional(bool, false)<br/>      provenance      = optional(bool, false)<br/>      segment_report       = optional(bool, false)<br/>      policy_normalization = optional(bool, false)<br/>      connectivity_graph   = optional(bool, false)<br/>      policy_diff = optional(object({<br/>        previous_reachability = optional(map(string))<br/>      }), {})<br/>      assertions = optional(object({<br/>        must_deny = optional(list(object({<br/>          from = object({<br/>            network_cidr         = string<br/>            secondary_cidrs      = optional(list(string), [])<br/>            ipv6_network_cidr    = optional(string)<br/>            ipv6_secondary_cidrs = optional(list(string), [])<br/>          })<br/>          to = object({<br/>            network_cidr         = string<br/>            secondary_cidrs      = optional(list(string), [])<br/>            ipv6_network_cidr    = optional(string)<br/>            ipv6_secondary_cidrs = optional(list(string), [])<br/>          })<br/>        })), [])<br/>        must_permit = optional(list(object({<br/>          from = object({<br/>            network_cidr         = string<br/>            secondary_cidrs      = optional(list(string), [])<br/>            ipv6_network_cidr    = optional(string)<br/>            ipv6_secondary_cidrs = optional(list(string), [])<br/>          })<br/>          to = object({<br/>            network_cidr         = string<br/>            secondary_cidrs      = optional(list(string), [])<br/>            ipv6_network_cidr    = optional(string)<br/>            ipv6_secondary_cidrs = optional(list(string), [])<br/>          })<br/>        })), [])<br/>      }))<br/>      equivalence = optional(object({<br/>        equivalent_routing_policy = optional(object({<br/>          default = string<br/>          deny = optional(list(object({<br/>            from = object({<br/>              network_cidr         = string<br/>              secondary_cidrs      = optional(list(string), [])<br/>              ipv6_network_cidr    = optional(string)<br/>              ipv6_secondary_cidrs = optional(list(string), [])<br/>            })<br/>            to = object({<br/>              network_cidr         = string<br/>              secondary_cidrs      = optional(list(string), [])<br/>              ipv6_network_cidr    = optional(string)<br/>              ipv6_secondary_cidrs = optional(list(string), [])<br/>            })<br/>          })), [])<br/>          allow = optional(list(object({<br/>            from = object({<br/>              network_cidr         = string<br/>              secondary_cidrs      = optional(list(string), [])<br/>              ipv6_network_cidr    = optional(string)<br/>              ipv6_secondary_cidrs = optional(list(string), [])<br/>            })<br/>            to = object({<br/>              network_cidr         = string<br/>              secondary_cidrs      = optional(list(string), [])<br/>              ipv6_network_cidr    = optional(string)<br/>              ipv6_secondary_cidrs = optional(list(string), [])<br/>            })<br/>          })), [])<br/>          segments = optional(map(list(object({<br/>            network_cidr         = string<br/>            secondary_cidrs      = optional(list(string), [])<br/>            ipv6_network_cidr    = optional(string)<br/>            ipv6_secondary_cidrs = optional(list(string), [])<br/>          }))), {})<br/>        }))<br/>      }), {})<br/>    }), {})<br/>    local = object({<br/>      amazon_side_asn = number<br/>      blackhole = optional(object({<br/>        cidrs      = optional(list(string), [])<br/>        ipv6_cidrs = optional(list(string), [])<br/>      }), {})<br/>      centralized_routers = optional(map(object({<br/>        account_id      = string<br/>        amazon_side_asn = string<br/>        full_name       = string<br/>        id              = string<br/>        name            = string<br/>        region          = string<br/>        route_table_id  = string<br/>        vpcs = optional(map(object({<br/>          id                      = string<br/>          name                    = string<br/>          full_name               = string<br/>          network_cidr            = string<br/>          secondary_cidrs         = list(string)<br/>          ipv6_network_cidr       = string<br/>          ipv6_secondary_cidrs    = list(string)<br/>          private_route_table_ids = list(string)<br/>          public_route_table_ids  = list(string)<br/>        })), {})<br/>      })), {})<br/>    })<br/>    peer = object({<br/>      amazon_side_asn = number<br/>      blackhole = optional(object({<br/>        cidrs      = optional(list(string), [])<br/>        ipv6_cidrs = optional(list(string), [])<br/>      }), {})<br/>      centralized_routers = optional(map(object({<br/>        account_id      = string<br/>        amazon_side_asn = string<br/>        full_name       = string<br/>        id              = string<br/>        name            = string<br/>        region          = string<br/>        route_table_id  = string<br/>        vpcs = optional(map(object({<br/>          id                      = string<br/>          name                    = string<br/>          full_name               = string<br/>          network_cidr            = string<br/>          secondary_cidrs         = list(string)<br/>          ipv6_network_cidr       = string<br/>          ipv6_secondary_cidrs    = list(string)<br/>          private_route_table_ids = list(string)<br/>          public_route_table_ids  = list(string)<br/>        })), {})<br/>      })), {})<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional Tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_local"></a> [local](#output\_local) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_peer"></a> [peer](#output\_peer) | n/a |
