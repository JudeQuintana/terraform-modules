# five
locals {
  # build new five vpc routes to one tgw vpcs
  five_vpc_routes_to_one_tgw_vpcs = [
    for five_route_table_id_and_one_tgw_network_cidr in setproduct(local.five_tgw_vpc_routes_route_table_ids, local.one_tgw_vpc_network_cidrs) : {
      route_table_id         = five_route_table_id_and_one_tgw_network_cidr[0]
      destination_cidr_block = five_route_table_id_and_one_tgw_network_cidr[1]
  }]

  five_tgw_new_vpc_routes_to_one_tgw_vpcs = {
    for this in local.five_vpc_routes_to_one_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_five_vpc_routes_to_one_tgw_vpcs" {
  provider = aws.five

  for_each = local.five_tgw_new_vpc_routes_to_one_tgw_vpcs

  transit_gateway_id     = local.five_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  # build new five vpc routes to two tgw vpcs
  five_vpc_routes_to_two_tgw_vpcs = [
    for five_route_table_id_and_two_tgw_network_cidr in setproduct(local.five_tgw_vpc_routes_route_table_ids, local.two_tgw_vpc_network_cidrs) : {
      route_table_id         = five_route_table_id_and_two_tgw_network_cidr[0]
      destination_cidr_block = five_route_table_id_and_two_tgw_network_cidr[1]
  }]

  five_tgw_new_vpc_routes_to_two_tgw_vpcs = {
    for this in local.five_vpc_routes_to_two_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_five_vpc_routes_to_two_tgw_vpcs" {
  provider = aws.five

  for_each = local.five_tgw_new_vpc_routes_to_two_tgw_vpcs

  transit_gateway_id     = local.five_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  # build new five vpc routes to three tgw vpcs
  five_vpc_routes_to_three_tgw_vpcs = [
    for five_route_table_id_and_three_tgw_network_cidr in setproduct(local.five_tgw_vpc_routes_route_table_ids, local.three_tgw_vpc_network_cidrs) : {
      route_table_id         = five_route_table_id_and_three_tgw_network_cidr[0]
      destination_cidr_block = five_route_table_id_and_three_tgw_network_cidr[1]
  }]

  five_tgw_new_vpc_routes_to_three_tgw_vpcs = {
    for this in local.five_vpc_routes_to_three_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_five_vpc_routes_to_three_tgw_vpcs" {
  provider = aws.five

  for_each = local.five_tgw_new_vpc_routes_to_three_tgw_vpcs

  transit_gateway_id     = local.five_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  # build new five vpc routes to four tgw vpcs
  five_vpc_routes_to_four_tgw_vpcs = [
    for five_route_table_id_and_four_tgw_network_cidr in setproduct(local.five_tgw_vpc_routes_route_table_ids, local.four_tgw_vpc_network_cidrs) : {
      route_table_id         = five_route_table_id_and_four_tgw_network_cidr[0]
      destination_cidr_block = five_route_table_id_and_four_tgw_network_cidr[1]
  }]

  five_tgw_new_vpc_routes_to_four_tgw_vpcs = {
    for this in local.five_vpc_routes_to_four_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_five_vpc_routes_to_four_tgw_vpcs" {
  provider = aws.five

  for_each = local.five_tgw_new_vpc_routes_to_four_tgw_vpcs

  transit_gateway_id     = local.five_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  # build new five vpc routes to six tgw vpcs
  five_vpc_routes_to_six_tgw_vpcs = [
    for five_route_table_id_and_six_tgw_network_cidr in setproduct(local.five_tgw_vpc_routes_route_table_ids, local.six_tgw_vpc_network_cidrs) : {
      route_table_id         = five_route_table_id_and_six_tgw_network_cidr[0]
      destination_cidr_block = five_route_table_id_and_six_tgw_network_cidr[1]
  }]

  five_tgw_new_vpc_routes_to_six_tgw_vpcs = {
    for this in local.five_vpc_routes_to_six_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_five_vpc_routes_to_six_tgw_vpcs" {
  provider = aws.five

  for_each = local.five_tgw_new_vpc_routes_to_six_tgw_vpcs

  transit_gateway_id     = local.five_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

