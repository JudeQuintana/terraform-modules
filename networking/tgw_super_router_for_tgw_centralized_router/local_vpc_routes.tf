# ipv4
resource "aws_route" "this_local_vpc_routes_to_peer_tgws" {
  provider = aws.local

  for_each = local.local_cross_region_ipv4_routes

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = lookup(local.local_tgws_vpc_route_table_id_to_tgw_id, each.value.route_table_id)
}

resource "aws_route" "this_local_vpc_routes_to_local_vpcs" {
  provider = aws.local

  for_each = local.local_intra_region_ipv4_routes

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = lookup(local.local_tgws_vpc_route_table_id_to_tgw_id, each.value.route_table_id)
}

# ipv6
resource "aws_route" "this_local_vpc_ipv6_routes_to_peer_tgws" {
  provider = aws.local

  for_each = local.local_cross_region_ipv6_routes

  route_table_id              = each.value.route_table_id
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  transit_gateway_id          = lookup(local.local_tgws_vpc_route_table_id_to_tgw_id, each.value.route_table_id)
}

resource "aws_route" "this_local_vpc_ipv6_routes_to_local_vpcs" {
  provider = aws.local

  for_each = local.local_intra_region_ipv6_routes

  route_table_id              = each.value.route_table_id
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  transit_gateway_id          = lookup(local.local_tgws_vpc_route_table_id_to_tgw_id, each.value.route_table_id)
}

