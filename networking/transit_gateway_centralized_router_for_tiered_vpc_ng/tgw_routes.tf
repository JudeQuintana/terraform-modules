locals {
  ipv4_network_cidr_to_vpc_id = merge([
    for this in var.centralized_router.vpcs : {
      for network_cidr in concat([this.network_cidr], this.secondary_cidrs) :
      network_cidr => this.id
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
    for this in var.centralized_router.vpcs : {
      for ipv6_network_cidr in concat(compact([this.ipv6_network_cidr]), this.ipv6_secondary_cidrs) :
      ipv6_network_cidr => this.id
  }]...)
}

resource "aws_ec2_transit_gateway_route" "this_tgw_ipv6_routes_to_vpcs" {
  for_each = local.ipv6_network_cidr_to_vpc_id

  destination_cidr_block         = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.value).id
}

locals {
  propagate_routes_vpc_id_to_vpc_attachment = { for vpc_id, this in local.vpc_id_to_vpc_attachment : vpc_id => this if var.centralized_router.propagate_routes }
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = local.propagate_routes_vpc_id_to_vpc_attachment

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}

