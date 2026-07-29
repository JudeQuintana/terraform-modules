locals {
  # combine all VPCs from all three regions into one map for policy evaluation
  all_vpcs = merge(
    local.one_tgw.vpcs,
    local.two_tgw.vpcs,
    local.three_tgw.vpcs
  )

  # track which route_table_ids belong to which region
  one_route_table_ids   = toset(flatten([for vpc in local.one_tgw.vpcs : concat(vpc.private_route_table_ids, vpc.public_route_table_ids)]))
  two_route_table_ids   = toset(flatten([for vpc in local.two_tgw.vpcs : concat(vpc.private_route_table_ids, vpc.public_route_table_ids)]))
  three_route_table_ids = toset(flatten([for vpc in local.three_tgw.vpcs : concat(vpc.private_route_table_ids, vpc.public_route_table_ids)]))

  # track which CIDRs belong to which region
  one_network_cidrs   = toset(flatten([for vpc in local.one_tgw.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)]))
  two_network_cidrs   = toset(flatten([for vpc in local.two_tgw.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)]))
  three_network_cidrs = toset(flatten([for vpc in local.three_tgw.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)]))
}

module "cross_region_routes" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/transit_gateway_centralized_router_for_tiered_vpc_ng/modules/generate_routes_to_other_vpcs?ref=init-deny-policy"

  vpcs   = local.all_vpcs
  policy = var.policy
}

locals {
  # filter to only cross-region routes per region
  # region one: route_table belongs to one, destination belongs to two or three
  one_cross_region_ipv4_routes = {
    for this in module.cross_region_routes.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
    if contains(local.one_route_table_ids, this.route_table_id) && !contains(local.one_network_cidrs, this.destination_cidr_block)
  }

  # region two: route_table belongs to two, destination belongs to one or three
  two_cross_region_ipv4_routes = {
    for this in module.cross_region_routes.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
    if contains(local.two_route_table_ids, this.route_table_id) && !contains(local.two_network_cidrs, this.destination_cidr_block)
  }

  # region three: route_table belongs to three, destination belongs to one or two
  three_cross_region_ipv4_routes = {
    for this in module.cross_region_routes.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
    if contains(local.three_route_table_ids, this.route_table_id) && !contains(local.three_network_cidrs, this.destination_cidr_block)
  }
}
