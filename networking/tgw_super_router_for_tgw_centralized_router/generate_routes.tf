locals {
  all_vpcs = merge(
    merge([for this in local.local_tgws : this.vpcs]...),
    merge([for this in local.peer_tgws : this.vpcs]...)
  )

  # vpc routes within the same tgw are already managed by the centralized router
  # these will be used to filter out routes that already exist
  local_tgw_vpc_routes = toset(flatten([
    for this in local.local_tgws : [
      for pair in setproduct(
        flatten([for vpc in this.vpcs : concat(vpc.private_route_table_ids, vpc.public_route_table_ids)]),
        flatten([for vpc in this.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)])
        ) : {
        route_table_id         = pair[0]
        destination_cidr_block = pair[1]
      }
    ]
  ]))

  peer_tgw_vpc_routes = toset(flatten([
    for this in local.peer_tgws : [
      for pair in setproduct(
        flatten([for vpc in this.vpcs : concat(vpc.private_route_table_ids, vpc.public_route_table_ids)]),
        flatten([for vpc in this.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)])
        ) : {
        route_table_id         = pair[0]
        destination_cidr_block = pair[1]
      }
    ]
  ]))

  # ipv6 self-route exclusion sets
  local_tgw_vpc_ipv6_routes = toset(flatten([
    for this in local.local_tgws : [
      for pair in setproduct(
        flatten([for vpc in this.vpcs : concat(vpc.private_route_table_ids, vpc.public_route_table_ids)]),
        flatten([for vpc in this.vpcs : concat(compact([vpc.ipv6_network_cidr]), vpc.ipv6_secondary_cidrs)])
        ) : {
        route_table_id              = pair[0]
        destination_ipv6_cidr_block = pair[1]
      }
    ]
  ]))

  peer_tgw_vpc_ipv6_routes = toset(flatten([
    for this in local.peer_tgws : [
      for pair in setproduct(
        flatten([for vpc in this.vpcs : concat(vpc.private_route_table_ids, vpc.public_route_table_ids)]),
        flatten([for vpc in this.vpcs : concat(compact([vpc.ipv6_network_cidr]), vpc.ipv6_secondary_cidrs)])
        ) : {
        route_table_id              = pair[0]
        destination_ipv6_cidr_block = pair[1]
      }
    ]
  ]))
}

module "this_generate_routes_to_other_vpcs" {
  #source = "git@github.com:JudeQuintana/terraform-modules.git//networking/generate_routes_to_other_vpcs?ref=v1.10.0"
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/generate_routes_to_other_vpcs?ref=init-deny-policy"

  vpcs           = local.all_vpcs
  routing_policy = var.routing_policy
}

locals {
  # local VPC routes to peer CIDRs (cross-region)
  local_cross_region_ipv4_routes = {
    for this in module.this_generate_routes_to_other_vpcs.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
    if contains(local.local_tgws_vpc_route_table_ids, this.route_table_id) && contains(local.peer_tgws_vpc_network_cidrs, this.destination_cidr_block)
  }

  # local VPC routes to other local VPCs (intra-region)
  local_intra_region_ipv4_routes = {
    for this in module.this_generate_routes_to_other_vpcs.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
    if contains(local.local_tgws_vpc_route_table_ids, this.route_table_id) && contains(local.local_tgws_vpc_network_cidrs, this.destination_cidr_block) && !contains(local.local_tgw_vpc_routes, this)
  }

  # peer VPC routes to local CIDRs (cross-region)
  peer_cross_region_ipv4_routes = {
    for this in module.this_generate_routes_to_other_vpcs.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
    if contains(local.peer_tgws_vpc_route_table_ids, this.route_table_id) && contains(local.local_tgws_vpc_network_cidrs, this.destination_cidr_block)
  }

  # peer VPC routes to other peer VPCs (intra-region)
  peer_intra_region_ipv4_routes = {
    for this in module.this_generate_routes_to_other_vpcs.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
    if contains(local.peer_tgws_vpc_route_table_ids, this.route_table_id) && contains(local.peer_tgws_vpc_network_cidrs, this.destination_cidr_block) && !contains(local.peer_tgw_vpc_routes, this)
  }

  # ipv6
  # local VPC routes to peer IPv6 CIDRs (cross-region)
  local_cross_region_ipv6_routes = {
    for this in module.this_generate_routes_to_other_vpcs.ipv6 :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
    if contains(local.local_tgws_vpc_route_table_ids, this.route_table_id) && contains(local.peer_tgws_vpc_ipv6_network_cidrs, this.destination_ipv6_cidr_block)
  }

  # local VPC routes to other local VPCs IPv6 (intra-region)
  local_intra_region_ipv6_routes = {
    for this in module.this_generate_routes_to_other_vpcs.ipv6 :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
    if contains(local.local_tgws_vpc_route_table_ids, this.route_table_id) && contains(local.local_tgws_vpc_ipv6_network_cidrs, this.destination_ipv6_cidr_block) && !contains(local.local_tgw_vpc_ipv6_routes, this)
  }

  # peer VPC routes to local IPv6 CIDRs (cross-region)
  peer_cross_region_ipv6_routes = {
    for this in module.this_generate_routes_to_other_vpcs.ipv6 :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
    if contains(local.peer_tgws_vpc_route_table_ids, this.route_table_id) && contains(local.local_tgws_vpc_ipv6_network_cidrs, this.destination_ipv6_cidr_block)
  }

  # peer VPC routes to other peer VPCs IPv6 (intra-region)
  peer_intra_region_ipv6_routes = {
    for this in module.this_generate_routes_to_other_vpcs.ipv6 :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
    if contains(local.peer_tgws_vpc_route_table_ids, this.route_table_id) && contains(local.peer_tgws_vpc_ipv6_network_cidrs, this.destination_ipv6_cidr_block) && !contains(local.peer_tgw_vpc_ipv6_routes, this)
  }
}
