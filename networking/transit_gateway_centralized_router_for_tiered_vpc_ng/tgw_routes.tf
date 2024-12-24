locals {
  ipv4_network_cidr_to_vpc_id = merge([
    for this in local.vpcs : {
      for network_cidr in concat([this.network_cidr], this.secondary_cidrs) :
      network_cidr => this.id
      if !contains(var.centralized_router.blackhole.cidrs, network_cidr)
  }]...)
}

resource "aws_ec2_transit_gateway_route" "this_tgw_routes_to_vpcs" {
  for_each = local.ipv4_network_cidr_to_vpc_id

  destination_cidr_block         = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.value).id
}

locals {
  ipv6_network_cidr_to_vpc_id = merge([
    for this in local.vpcs : {
      for ipv6_network_cidr in concat(compact([this.ipv6_network_cidr]), this.ipv6_secondary_cidrs) :
      ipv6_network_cidr => this.id
      if !contains(var.centralized_router.blackhole.ipv6_cidrs, ipv6_network_cidr)
  }]...)
}

resource "aws_ec2_transit_gateway_route" "this_tgw_ipv6_routes_to_vpcs" {
  for_each = local.ipv6_network_cidr_to_vpc_id

  destination_cidr_block         = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.value).id
}

# propagate routes for all attachments
locals {
  propagate_routes_vpc_id_to_vpc_attachment = { for vpc_id, this in local.vpc_id_to_vpc_attachment : vpc_id => this if var.centralized_router.propagate_routes }
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = local.propagate_routes_vpc_id_to_vpc_attachment

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}

# blackhole routes
locals {
  blackhole_all_cidrs = toset(concat(var.centralized_router.blackhole.cidrs, var.centralized_router.blackhole.ipv6_cidrs))
}

resource "aws_ec2_transit_gateway_route" "this_blackholes" {
  for_each = local.blackhole_all_cidrs

  # destination_cidr_block can be ipv4 or ipv6 (no separate attribute or resource)
  destination_cidr_block         = each.value
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id

  # blackhole routes are filtered out from each dependant resource
  # which gives the ability to gracefully override any automatic static tgw route (0.0.0.0/0, etc)
  depends_on = [
    aws_ec2_transit_gateway_route.this_tgw_routes_to_vpcs,
    aws_ec2_transit_gateway_route.this_tgw_ipv6_routes_to_vpcs,
    aws_ec2_transit_gateway_route.this_centralized_egress_tgw_central_vpc_route_any
  ]
}
