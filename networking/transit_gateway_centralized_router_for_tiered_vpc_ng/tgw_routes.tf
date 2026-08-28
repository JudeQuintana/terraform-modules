# one route table for all vpc network_cidrs
resource "aws_ec2_transit_gateway_route_table" "this" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags = merge(
    local.default_tags,
    { Name = local.centralized_router_full_name }
  )
}

# ipv4
locals {
  ipv4_network_cidr_to_vpc_name = merge([
    for this in local.vpcs : {
      for network_cidr in concat([this.network_cidr], this.secondary_cidrs) :
      network_cidr => this.name
      if !contains(var.centralized_router.blackhole.cidrs, network_cidr)
  }]...)
}

resource "aws_ec2_transit_gateway_route" "this_tgw_routes_to_vpcs" {
  for_each = local.ipv4_network_cidr_to_vpc_name

  destination_cidr_block         = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.value).id
}

# ipv6
locals {
  ipv6_network_cidr_to_vpc_name = merge([
    for this in local.vpcs : {
      for ipv6_network_cidr in concat(compact([this.ipv6_network_cidr]), this.ipv6_secondary_cidrs) :
      ipv6_network_cidr => this.name
      if !contains(var.centralized_router.blackhole.ipv6_cidrs, ipv6_network_cidr)
  }]...)
}

resource "aws_ec2_transit_gateway_route" "this_tgw_ipv6_routes_to_vpcs" {
  for_each = local.ipv6_network_cidr_to_vpc_name

  destination_cidr_block         = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.value).id
}

