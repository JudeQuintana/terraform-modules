locals {
  one_vpc_routes_to_two_tgw_vpcs = [
    for one_route_table_id_and_two_tgw_network_cidr in setproduct(local.one_tgw_vpc_route_table_ids, local.two_tgw_vpc_network_cidrs) : {
      route_table_id         = one_route_table_id_and_two_tgw_network_cidr[0]
      destination_cidr_block = one_route_table_id_and_two_tgw_network_cidr[1]
  }]

  one_tgw_new_vpc_routes_to_two_tgw_vpcs = {
    for this in local.one_vpc_routes_to_two_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_one_vpc_routes_to_two_tgw_vpcs" {
  provider = aws.one

  for_each = local.one_tgw_new_vpc_routes_to_two_tgw_vpcs

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = local.one_tgw.id
}

locals {
  one_vpc_routes_to_three_tgw_vpcs = [
    for one_route_table_id_and_two_tgw_network_cidr in setproduct(local.one_tgw_vpc_route_table_ids, local.three_tgw_vpc_network_cidrs) : {
      route_table_id         = one_route_table_id_and_two_tgw_network_cidr[0]
      destination_cidr_block = one_route_table_id_and_two_tgw_network_cidr[1]
  }]

  one_tgw_new_vpc_routes_to_three_tgw_vpcs = {
    for this in local.one_vpc_routes_to_three_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_one_vpc_routes_to_three_tgw_vpcs" {
  provider = aws.one

  for_each = local.one_tgw_new_vpc_routes_to_three_tgw_vpcs

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = local.one_tgw.id
}

# ipv6
locals {
  one_vpc_ipv6_routes_to_two_tgw_vpcs = [
    for one_route_table_id_and_two_tgw_ipv6_network_cidr in setproduct(local.one_tgw_vpc_route_table_ids, local.two_tgw_vpc_ipv6_network_cidrs) : {
      route_table_id              = one_route_table_id_and_two_tgw_ipv6_network_cidr[0]
      destination_ipv6_cidr_block = one_route_table_id_and_two_tgw_ipv6_network_cidr[1]
  }]

  one_tgw_new_vpc_ipv6_routes_to_two_tgw_vpcs = {
    for this in local.one_vpc_ipv6_routes_to_two_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
  }
}

resource "aws_route" "this_one_vpc_ipv6_routes_to_two_tgw_vpcs" {
  provider = aws.one

  for_each = local.one_tgw_new_vpc_ipv6_routes_to_two_tgw_vpcs

  route_table_id              = each.value.route_table_id
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  transit_gateway_id          = local.one_tgw.id
}

locals {
  one_vpc_ipv6_routes_to_three_tgw_vpcs = [
    for one_route_table_id_and_three_tgw_ipv6_network_cidr in setproduct(local.one_tgw_vpc_route_table_ids, local.three_tgw_vpc_ipv6_network_cidrs) : {
      route_table_id              = one_route_table_id_and_three_tgw_ipv6_network_cidr[0]
      destination_ipv6_cidr_block = one_route_table_id_and_three_tgw_ipv6_network_cidr[1]
  }]

  one_tgw_new_vpc_ipv6_routes_to_three_tgw_vpcs = {
    for this in local.one_vpc_ipv6_routes_to_three_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
  }
}

resource "aws_route" "this_one_vpc_ipv6_routes_to_three_tgw_vpcs" {
  provider = aws.one

  for_each = local.one_tgw_new_vpc_ipv6_routes_to_three_tgw_vpcs

  route_table_id              = each.value.route_table_id
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  transit_gateway_id          = local.one_tgw.id
}

