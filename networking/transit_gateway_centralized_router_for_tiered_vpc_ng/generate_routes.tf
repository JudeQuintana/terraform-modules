# Create routes to other VPC network_cidrs in private and public route tables for each VPC
module "this_generate_routes_to_other_vpcs" {
  source = "../generate_routes_to_other_vpcs"

  routing_policy            = var.routing_policy
  vpcs                      = local.vpcs
  previous_reachability     = var.previous_reachability
  equivalent_routing_policy = var.equivalent_routing_policy
}

locals {
  route_format = "%s|%s"
  # ipv4
  vpc_routes_to_other_vpcs = {
    for this in module.this_generate_routes_to_other_vpcs.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
  # ipv6
  ipv6_vpc_routes_to_other_vpcs = {
    for this in module.this_generate_routes_to_other_vpcs.ipv6 :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
  }
}

