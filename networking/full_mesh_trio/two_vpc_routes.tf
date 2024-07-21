# ipv4
locals {
  two_vpc_routes_to_one_tgw_vpcs = [
    for two_route_table_id_and_one_tgw_network_cidr in setproduct(local.two_tgw_vpc_route_table_ids, local.one_tgw_vpc_network_cidrs) : {
      route_table_id         = two_route_table_id_and_one_tgw_network_cidr[0]
      destination_cidr_block = two_route_table_id_and_one_tgw_network_cidr[1]
  }]

  two_tgw_new_vpc_routes_to_one_tgw_vpcs = {
    for this in local.two_vpc_routes_to_one_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_routes_to_one_tgw_vpcs" {
  provider = aws.two

  for_each = local.two_tgw_new_vpc_routes_to_one_tgw_vpcs

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = local.two_tgw.id
}

locals {
  two_vpc_routes_to_three_tgw_vpcs = [
    for two_route_table_id_and_three_tgw_network_cidr in setproduct(local.two_tgw_vpc_route_table_ids, local.three_tgw_vpc_network_cidrs) : {
      route_table_id         = two_route_table_id_and_three_tgw_network_cidr[0]
      destination_cidr_block = two_route_table_id_and_three_tgw_network_cidr[1]
  }]

  two_tgw_new_vpc_routes_to_three_tgw_vpcs = {
    for this in local.two_vpc_routes_to_three_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_routes_to_three_tgw_vpcs" {
  provider = aws.two

  for_each = local.two_tgw_new_vpc_routes_to_three_tgw_vpcs

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = local.two_tgw.id
}

# ipv6
locals {
  two_vpc_ipv6_routes_to_one_tgw_vpcs = [
    for two_route_table_id_and_one_tgw_ipv6_network_cidr in setproduct(local.two_tgw_vpc_route_table_ids, local.one_tgw_vpc_ipv6_network_cidrs) : {
      route_table_id              = two_route_table_id_and_one_tgw_ipv6_network_cidr[0]
      destination_ipv6_cidr_block = two_route_table_id_and_one_tgw_ipv6_network_cidr[1]
  }]

  two_tgw_new_vpc_ipv6_routes_to_one_tgw_vpcs = {
    for this in local.two_vpc_ipv6_routes_to_one_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_ipv6_routes_to_one_tgw_vpcs" {
  provider = aws.two

  for_each = local.two_tgw_new_vpc_ipv6_routes_to_one_tgw_vpcs

  route_table_id              = each.value.route_table_id
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  transit_gateway_id          = local.two_tgw.id
}

locals {
  two_vpc_ipv6_routes_to_three_tgw_vpcs = [
    for two_route_table_id_and_three_tgw_ipv6_network_cidr in setproduct(local.two_tgw_vpc_route_table_ids, local.three_tgw_vpc_ipv6_network_cidrs) : {
      route_table_id              = two_route_table_id_and_three_tgw_ipv6_network_cidr[0]
      destination_ipv6_cidr_block = two_route_table_id_and_three_tgw_ipv6_network_cidr[1]
  }]

  two_tgw_new_vpc_ipv6_routes_to_three_tgw_vpcs = {
    for this in local.two_vpc_ipv6_routes_to_three_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_ipv6_routes_to_three_tgw_vpcs" {
  provider = aws.two

  for_each = local.two_tgw_new_vpc_ipv6_routes_to_three_tgw_vpcs

  route_table_id              = each.value.route_table_id
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  transit_gateway_id          = local.two_tgw.id
}
