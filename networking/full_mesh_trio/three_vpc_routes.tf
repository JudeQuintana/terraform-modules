# ipv4
locals {
  # build new three vpc routes to one tgw vpcs
  three_vpc_routes_to_one_tgw_vpcs = [
    for three_route_table_id_and_one_tgw_network_cidr in setproduct(local.three_tgw_vpc_route_table_ids, local.one_tgw_vpc_network_cidrs) : {
      route_table_id         = three_route_table_id_and_one_tgw_network_cidr[0]
      destination_cidr_block = three_route_table_id_and_one_tgw_network_cidr[1]
  }]

  three_tgw_new_vpc_routes_to_one_tgw_vpcs = {
    for this in local.three_vpc_routes_to_one_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_three_vpc_routes_to_one_tgw_vpcs" {
  provider = aws.three

  for_each = local.three_tgw_new_vpc_routes_to_one_tgw_vpcs

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = local.three_tgw.id
}

locals {
  three_vpc_routes_to_two_tgw_vpcs = [
    for three_route_table_id_and_two_tgw_network_cidr in setproduct(local.three_tgw_vpc_route_table_ids, local.two_tgw_vpc_network_cidrs) : {
      route_table_id         = three_route_table_id_and_two_tgw_network_cidr[0]
      destination_cidr_block = three_route_table_id_and_two_tgw_network_cidr[1]
  }]

  three_tgw_new_vpc_routes_to_two_tgw_vpcs = {
    for this in local.three_vpc_routes_to_two_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_three_vpc_routes_to_two_tgw_vpcs" {
  provider = aws.three

  for_each = local.three_tgw_new_vpc_routes_to_two_tgw_vpcs

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = local.three_tgw.id
}

#ipv6
locals {
  # build new three vpc ipv6 routes to one tgw vpcs
  three_vpc_ipv6_routes_to_one_tgw_vpcs = [
    for three_route_table_id_and_one_tgw_ipv6_network_cidr in setproduct(local.three_tgw_vpc_route_table_ids, local.one_tgw_vpc_ipv6_network_cidrs) : {
      route_table_id              = three_route_table_id_and_one_tgw_ipv6_network_cidr[0]
      destination_ipv6_cidr_block = three_route_table_id_and_one_tgw_ipv6_network_cidr[1]
  }]

  three_tgw_new_vpc_ipv6_routes_to_one_tgw_vpcs = {
    for this in local.three_vpc_ipv6_routes_to_one_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
  }
}

resource "aws_route" "this_three_vpc_ipv6_routes_to_one_tgw_vpcs" {
  provider = aws.three

  for_each = local.three_tgw_new_vpc_ipv6_routes_to_one_tgw_vpcs

  route_table_id              = each.value.route_table_id
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  transit_gateway_id          = local.three_tgw.id
}

locals {
  three_vpc_ipv6_routes_to_two_tgw_vpcs = [
    for three_route_table_id_and_two_tgw_ipv6_network_cidr in setproduct(local.three_tgw_vpc_route_table_ids, local.two_tgw_vpc_ipv6_network_cidrs) : {
      route_table_id              = three_route_table_id_and_two_tgw_ipv6_network_cidr[0]
      destination_ipv6_cidr_block = three_route_table_id_and_two_tgw_ipv6_network_cidr[1]
  }]

  three_tgw_new_vpc_ipv6_routes_to_two_tgw_vpcs = {
    for this in local.three_vpc_ipv6_routes_to_two_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
  }
}

resource "aws_route" "this_three_vpc_ipv6_routes_to_two_tgw_vpcs" {
  provider = aws.three

  for_each = local.three_tgw_new_vpc_ipv6_routes_to_two_tgw_vpcs

  route_table_id              = each.value.route_table_id
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  transit_gateway_id          = local.three_tgw.id
}
