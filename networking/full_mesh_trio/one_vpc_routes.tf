# ipv4
resource "aws_route" "this_one_cross_region_vpc_routes" {
  provider = aws.one

  for_each = local.one_cross_region_ipv4_routes

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = local.one_tgw.id
}

# ipv6
resource "aws_route" "this_one_cross_region_ipv6_vpc_routes" {
  provider = aws.one

  for_each = local.one_cross_region_ipv6_routes

  route_table_id              = each.value.route_table_id
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  transit_gateway_id          = local.one_tgw.id
}
