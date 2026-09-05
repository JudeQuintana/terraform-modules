# Full Mesh Trio

Cross-region full mesh between three Centralized Routers. Builds TGW peering
attachments and static routes across all three TGWs, then compiles an optional
routing policy (deny > allow > segments > default) into cross-region VPC route
table entries. Operates as the Global IR, evaluating policy across all regions
in a single declaration.

`v1.12.0`:
- Five new inspect toggles: `assertions`, `blast_radius`, `segment_report`, `policy_normalization`, `connectivity_graph`.
- Boolean-gated outputs for `segment_report`, `policy_normalization`, and `connectivity_graph`.
- Input-gated outputs for `assertions` (object with `must_deny`/`must_permit`) and `blast_radius` (derived from `policy_diff`).
- Connectivity graph writes a `.dot` file (raw DOT, not JSON).
- Uses `generate_routes_to_other_vpcs` v1.12.0.

`v1.11.0`:
- Breaking change: `routing_policy` is now required (no default). Matches Centralized Router interface.
- New `inspect` field nested inside `var.full_mesh_trio.inspect` for compiler semantic toolchain outputs.
- Three validations for `routing_policy`: default must be allow or deny, segment uniqueness
  with inline duplicate CIDRs, out-of-scope CIDRs with inline error.
- Three validations for `equivalent_routing_policy` with cross-field validation against in-scope VPCs.
- New `inspect.tf` for reachability, diagnostics, provenance, policy\_diff, and equivalence outputs.

`v1.10.0`:
- Breaking change: cross-region VPC routes now use policy compilation instead of VPC aggregate setproduct.
- Route resource names are consolidated and renamed.
- New `routing_policy` variable with four primitives and fixed precedence: deny > allow > segments > default.
- Dual-stack support: one policy declaration controls both IPv4 and IPv6 route generation.
- Scope-invariant: same policy evaluation as Centralized Router and Super Router.
- Uses `generate_routes_to_other_vpcs` v1.10.0 as the shared compilation unit.
![centralized-egress-dual-stack-full-mesh-trio](https://jq1-io.s3.us-east-1.amazonaws.com/dual-stack/centralized-egress-dual-stack-full-mesh-trio-v3-3.png)

`v1.9.0`:
- reorganize files
- ipv4 VPC routes for ipv4 secondary cidrs
- ipv4 TGW routes for ipv4 secondary cidrs
- ipv6 VPC routes for ipv6 network cidrs
- ipv6 TGW routes for ipv6 network cidrs
- ipv6 VPC routes for ipv6 secondary cidrs
- ipv6 TGW routes for ipv6 secondary cidrs
- moar validation
```
module "full_mesh_trio" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/full_mesh_trio?ref=v1.9.0"
...
```

`v1.7.5`:
- ipv4 VPC routes for ipv4 network cidrs
```
module "full_mesh_trio" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/full_mesh_trio?ref=v1.7.5"

  providers = {
    aws.one   = aws.use1
    aws.two   = aws.use2
    aws.three = aws.usw2
  }

 env_prefix = var.env_prefix
 full_mesh_trio = {
   one = {
     centralized_router = module.centralized_router_use1
   }
   two = {
     centralized_router = module.centralized_router_use2
   }
   three = {
     centralized_router = module.centralized_router_usw2
   }
 }
}

output "full_mesh_trio" {
 value = module.full_mesh_trio
}
```

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.61 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >=2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws.one"></a> [aws.one](#provider\_aws.one) | >=5.61 |
| <a name="provider_aws.three"></a> [aws.three](#provider\_aws.three) | >=5.61 |
| <a name="provider_aws.two"></a> [aws.two](#provider\_aws.two) | >=5.61 |
| <a name="provider_local"></a> [local](#provider\_local) | >=2.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_this_generate_routes_to_other_vpcs"></a> [this\_generate\_routes\_to\_other\_vpcs](#module\_this\_generate\_routes\_to\_other\_vpcs) | ../generate_routes_to_other_vpcs | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_ec2_transit_gateway_peering_attachment.this_one_to_this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment.this_three_to_this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment.this_two_to_this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this_one_to_this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this_three_to_this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_route.this_one_tgw_ipv6_routes_to_vpcs_in_three_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_one_tgw_ipv6_routes_to_vpcs_in_two_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_one_tgw_routes_to_vpcs_in_three_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_one_tgw_routes_to_vpcs_in_two_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_three_tgw_ipv6_routes_to_vpcs_in_one_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_three_tgw_ipv6_routes_to_vpcs_in_two_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_three_tgw_routes_to_vpcs_in_one_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_three_tgw_routes_to_vpcs_in_two_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_two_tgw_ipv6_routes_to_vpcs_in_one_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_two_tgw_ipv6_routes_to_vpcs_in_three_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_two_tgw_routes_to_vpcs_in_one_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.this_two_tgw_routes_to_vpcs_in_three_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_one_to_this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_one_to_this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_three_to_this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_three_to_this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_two_to_this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.this_two_to_this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_route.this_one_cross_region_ipv6_vpc_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_one_cross_region_vpc_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_three_cross_region_ipv6_vpc_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_three_cross_region_vpc_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_two_cross_region_ipv6_vpc_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.this_two_cross_region_vpc_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
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
| [aws_caller_identity.this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.this_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.this_three](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.this_two](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | prod, stage, test | `string` | n/a | yes |
| <a name="input_full_mesh_trio"></a> [full\_mesh\_trio](#input\_full\_mesh\_trio) | full mesh trio configuration | <pre>object({<br/>    name = string<br/>    routing_policy = object({<br/>      default = string<br/>      deny = optional(list(object({<br/>        from = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>        to = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>      })), [])<br/>      allow = optional(list(object({<br/>        from = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>        to = object({<br/>          network_cidr         = string<br/>          secondary_cidrs      = optional(list(string), [])<br/>          ipv6_network_cidr    = optional(string)<br/>          ipv6_secondary_cidrs = optional(list(string), [])<br/>        })<br/>      })), [])<br/>      segments = optional(map(list(object({<br/>        network_cidr         = string<br/>        secondary_cidrs      = optional(list(string), [])<br/>        ipv6_network_cidr    = optional(string)<br/>        ipv6_secondary_cidrs = optional(list(string), [])<br/>      }))), {})<br/>    })<br/>    inspect = optional(object({<br/>      reachability = optional(bool, false)<br/>      diagnostics  = optional(bool, false)<br/>      provenance      = optional(bool, false)<br/>      segment_report       = optional(bool, false)<br/>      policy_normalization = optional(bool, false)<br/>      connectivity_graph   = optional(bool, false)<br/>      policy_diff = optional(object({<br/>        previous_reachability = optional(map(string))<br/>      }), {})<br/>      assertions = optional(object({<br/>        must_deny = optional(list(object({<br/>          from = object({<br/>            network_cidr         = string<br/>            secondary_cidrs      = optional(list(string), [])<br/>            ipv6_network_cidr    = optional(string)<br/>            ipv6_secondary_cidrs = optional(list(string), [])<br/>          })<br/>          to = object({<br/>            network_cidr         = string<br/>            secondary_cidrs      = optional(list(string), [])<br/>            ipv6_network_cidr    = optional(string)<br/>            ipv6_secondary_cidrs = optional(list(string), [])<br/>          })<br/>        })), [])<br/>        must_permit = optional(list(object({<br/>          from = object({<br/>            network_cidr         = string<br/>            secondary_cidrs      = optional(list(string), [])<br/>            ipv6_network_cidr    = optional(string)<br/>            ipv6_secondary_cidrs = optional(list(string), [])<br/>          })<br/>          to = object({<br/>            network_cidr         = string<br/>            secondary_cidrs      = optional(list(string), [])<br/>            ipv6_network_cidr    = optional(string)<br/>            ipv6_secondary_cidrs = optional(list(string), [])<br/>          })<br/>        })), [])<br/>      }))<br/>      equivalence = optional(object({<br/>        equivalent_routing_policy = optional(object({<br/>          default = string<br/>          deny = optional(list(object({<br/>            from = object({<br/>              network_cidr         = string<br/>              secondary_cidrs      = optional(list(string), [])<br/>              ipv6_network_cidr    = optional(string)<br/>              ipv6_secondary_cidrs = optional(list(string), [])<br/>            })<br/>            to = object({<br/>              network_cidr         = string<br/>              secondary_cidrs      = optional(list(string), [])<br/>              ipv6_network_cidr    = optional(string)<br/>              ipv6_secondary_cidrs = optional(list(string), [])<br/>            })<br/>          })), [])<br/>          allow = optional(list(object({<br/>            from = object({<br/>              network_cidr         = string<br/>              secondary_cidrs      = optional(list(string), [])<br/>              ipv6_network_cidr    = optional(string)<br/>              ipv6_secondary_cidrs = optional(list(string), [])<br/>            })<br/>            to = object({<br/>              network_cidr         = string<br/>              secondary_cidrs      = optional(list(string), [])<br/>              ipv6_network_cidr    = optional(string)<br/>              ipv6_secondary_cidrs = optional(list(string), [])<br/>            })<br/>          })), [])<br/>          segments = optional(map(list(object({<br/>            network_cidr         = string<br/>            secondary_cidrs      = optional(list(string), [])<br/>            ipv6_network_cidr    = optional(string)<br/>            ipv6_secondary_cidrs = optional(list(string), [])<br/>          }))), {})<br/>        }))<br/>      }), {})<br/>    }), {})<br/>    one = object({<br/>      centralized_router = object({<br/>        account_id      = string<br/>        amazon_side_asn = string<br/>        full_name       = string<br/>        id              = string<br/>        name            = string<br/>        region          = string<br/>        route_table_id  = string<br/>        vpcs = optional(map(object({<br/>          id                      = string<br/>          name                    = string<br/>          network_cidr            = string<br/>          secondary_cidrs         = optional(list(string), [])<br/>          ipv6_network_cidr       = optional(string)<br/>          ipv6_secondary_cidrs    = optional(list(string), [])<br/>          private_route_table_ids = list(string)<br/>          public_route_table_ids  = list(string)<br/>        })), {})<br/>      })<br/>    })<br/>    two = object({<br/>      centralized_router = object({<br/>        account_id      = string<br/>        amazon_side_asn = string<br/>        full_name       = string<br/>        id              = string<br/>        name            = string<br/>        region          = string<br/>        route_table_id  = string<br/>        vpcs = optional(map(object({<br/>          id                      = string<br/>          name                    = string<br/>          network_cidr            = string<br/>          secondary_cidrs         = optional(list(string), [])<br/>          ipv6_network_cidr       = optional(string)<br/>          ipv6_secondary_cidrs    = optional(list(string), [])<br/>          private_route_table_ids = list(string)<br/>          public_route_table_ids  = list(string)<br/>        })), {})<br/>      })<br/>    })<br/>    three = object({<br/>      centralized_router = object({<br/>        account_id      = string<br/>        amazon_side_asn = string<br/>        full_name       = string<br/>        id              = string<br/>        name            = string<br/>        region          = string<br/>        route_table_id  = string<br/>        vpcs = optional(map(object({<br/>          id                      = string<br/>          name                    = string<br/>          network_cidr            = string<br/>          secondary_cidrs         = optional(list(string), [])<br/>          ipv6_network_cidr       = optional(string)<br/>          ipv6_secondary_cidrs    = optional(list(string), [])<br/>          private_route_table_ids = list(string)<br/>          public_route_table_ids  = list(string)<br/>        })), {})<br/>      })<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional Tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_peering"></a> [peering](#output\_peering) | n/a |
