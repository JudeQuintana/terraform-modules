locals {
  all_vpcs = merge(
    merge([for cr in local.local_tgws : cr.vpcs]...),
    merge([for cr in local.peer_tgws : cr.vpcs]...)
  )

  # routes within the same CR are already managed by the centralized router
  local_self_cr_routes = toset(flatten([
    for this in local.local_tgws : [
      for pair in setproduct(
        flatten([for vpc in values(this.vpcs) : concat(vpc.private_route_table_ids, vpc.public_route_table_ids)]),
        flatten([for vpc in values(this.vpcs) : concat([vpc.network_cidr], vpc.secondary_cidrs)])
      ) : format(local.route_format, pair[0], pair[1])
    ]
  ]))

  peer_self_cr_routes = toset(flatten([
    for this in local.peer_tgws : [
      for pair in setproduct(
        flatten([for vpc in values(this.vpcs) : concat(vpc.private_route_table_ids, vpc.public_route_table_ids)]),
        flatten([for vpc in values(this.vpcs) : concat([vpc.network_cidr], vpc.secondary_cidrs)])
      ) : format(local.route_format, pair[0], pair[1])
    ]
  ]))
}

module "cross_region_routes" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/transit_gateway_centralized_router_for_tiered_vpc_ng/modules/generate_routes_to_other_vpcs?ref=init-deny-policy"

  vpcs   = local.all_vpcs
  policy = var.policy
}

locals {
  # local VPC routes to peer CIDRs (cross-region)
  local_cross_region_ipv4_routes = {
    for this in module.cross_region_routes.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
    if contains(local.local_tgws_vpc_route_table_ids, this.route_table_id) && contains(local.peer_tgws_vpc_network_cidrs, this.destination_cidr_block)
  }

  # local VPC routes to other local VPCs (intra-region, cross-CR)
  local_intra_region_ipv4_routes = {
    for this in module.cross_region_routes.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
    if contains(local.local_tgws_vpc_route_table_ids, this.route_table_id) && contains(local.local_tgws_vpc_network_cidrs, this.destination_cidr_block) && !contains(local.local_self_cr_routes, format(local.route_format, this.route_table_id, this.destination_cidr_block))
  }

  # peer VPC routes to local CIDRs (cross-region)
  peer_cross_region_ipv4_routes = {
    for this in module.cross_region_routes.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
    if contains(local.peer_tgws_vpc_route_table_ids, this.route_table_id) && contains(local.local_tgws_vpc_network_cidrs, this.destination_cidr_block)
  }

  # peer VPC routes to other peer VPCs (intra-region, cross-CR)
  peer_intra_region_ipv4_routes = {
    for this in module.cross_region_routes.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
    if contains(local.peer_tgws_vpc_route_table_ids, this.route_table_id) && contains(local.peer_tgws_vpc_network_cidrs, this.destination_cidr_block) && !contains(local.peer_self_cr_routes, format(local.route_format, this.route_table_id, this.destination_cidr_block))
  }
}
