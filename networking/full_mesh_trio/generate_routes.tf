locals {
  # combine all VPCs from all three regions into one map for policy evaluation
  all_vpcs = merge(
    local.one_tgw.vpcs,
    local.two_tgw.vpcs,
    local.three_tgw.vpcs
  )
}

module "this_generate_routes_to_other_vpcs" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/transit_gateway_centralized_router_for_tiered_vpc_ng/modules/generate_routes_to_other_vpcs?ref=init-deny-policy"

  vpcs   = local.all_vpcs
  policy = var.policy
}

locals {
  # filter to only cross-region routes per region
  # region one: route_table belongs to one, destination belongs to two or three
  one_cross_region_ipv4_routes = {
    for this in module.this_generate_routes_to_other_vpcs.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
    if contains(local.one_tgw_vpc_route_table_ids, this.route_table_id) && !contains(local.one_tgw_vpc_network_cidrs, this.destination_cidr_block)
  }

  # region two: route_table belongs to two, destination belongs to one or three
  two_cross_region_ipv4_routes = {
    for this in module.this_generate_routes_to_other_vpcs.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
    if contains(local.two_tgw_vpc_route_table_ids, this.route_table_id) && !contains(local.two_tgw_vpc_network_cidrs, this.destination_cidr_block)
  }

  # region three: route_table belongs to three, destination belongs to one or two
  three_cross_region_ipv4_routes = {
    for this in module.this_generate_routes_to_other_vpcs.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
    if contains(local.three_tgw_vpc_route_table_ids, this.route_table_id) && !contains(local.three_tgw_vpc_network_cidrs, this.destination_cidr_block)
  }
}

