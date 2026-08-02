# ipv4
resource "aws_route" "this_three_cross_region_vpc_routes" {
  provider = aws.three

  for_each = local.three_cross_region_ipv4_routes

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = local.three_tgw.id
}

# ipv6
resource "aws_route" "this_three_cross_region_ipv6_vpc_routes" {
  provider = aws.three

  for_each = local.three_cross_region_ipv6_routes

  route_table_id              = each.value.route_table_id
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  transit_gateway_id          = local.three_tgw.id
}
