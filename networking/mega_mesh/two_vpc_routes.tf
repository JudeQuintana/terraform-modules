# two
locals {
  # build new two vpc routes to one tgw vpcs
  two_vpc_routes_to_one_tgw_vpcs = [
    for route_table_id_and_network_cidr in setproduct(local.two_tgw_vpc_route_table_ids, local.one_tgw_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_network_cidr[0]
      destination_cidr_block = route_table_id_and_network_cidr[1]
  }]

  two_tgw_new_vpc_routes_to_one_tgw_vpcs = {
    for this in local.two_vpc_routes_to_one_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_routes_to_one_tgw_vpcs" {
  provider = aws.two

  for_each = local.two_tgw_new_vpc_routes_to_one_tgw_vpcs

  transit_gateway_id     = local.two_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  two_vpc_routes_to_three_tgw_vpcs = [
    for route_table_id_and_network_cidr in setproduct(local.two_tgw_vpc_route_table_ids, local.three_tgw_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_network_cidr[0]
      destination_cidr_block = route_table_id_and_network_cidr[1]
  }]

  two_tgw_new_vpc_routes_to_three_tgw_vpcs = {
    for this in local.two_vpc_routes_to_three_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_routes_to_three_tgw_vpcs" {
  provider = aws.two

  for_each = local.two_tgw_new_vpc_routes_to_three_tgw_vpcs

  transit_gateway_id     = local.two_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  two_vpc_routes_to_four_tgw_vpcs = [
    for route_table_id_and_network_cidr in setproduct(local.two_tgw_vpc_route_table_ids, local.four_tgw_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_network_cidr[0]
      destination_cidr_block = route_table_id_and_network_cidr[1]
  }]

  two_tgw_new_vpc_routes_to_four_tgw_vpcs = {
    for this in local.two_vpc_routes_to_four_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_routes_to_four_tgw_vpcs" {
  provider = aws.two

  for_each = local.two_tgw_new_vpc_routes_to_four_tgw_vpcs

  transit_gateway_id     = local.two_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  two_vpc_routes_to_five_tgw_vpcs = [
    for route_table_id_and_network_cidr in setproduct(local.two_tgw_vpc_route_table_ids, local.five_tgw_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_network_cidr[0]
      destination_cidr_block = route_table_id_and_network_cidr[1]
  }]

  two_tgw_new_vpc_routes_to_five_tgw_vpcs = {
    for this in local.two_vpc_routes_to_five_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_routes_to_five_tgw_vpcs" {
  provider = aws.two

  for_each = local.two_tgw_new_vpc_routes_to_five_tgw_vpcs

  transit_gateway_id     = local.two_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  two_vpc_routes_to_six_tgw_vpcs = [
    for route_table_id_and_network_cidr in setproduct(local.two_tgw_vpc_route_table_ids, local.six_tgw_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_network_cidr[0]
      destination_cidr_block = route_table_id_and_network_cidr[1]
  }]

  two_tgw_new_vpc_routes_to_six_tgw_vpcs = {
    for this in local.two_vpc_routes_to_six_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_routes_to_six_tgw_vpcs" {
  provider = aws.two

  for_each = local.two_tgw_new_vpc_routes_to_six_tgw_vpcs

  transit_gateway_id     = local.two_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  two_vpc_routes_to_seven_tgw_vpcs = [
    for route_table_id_and_network_cidr in setproduct(local.two_tgw_vpc_route_table_ids, local.seven_tgw_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_network_cidr[0]
      destination_cidr_block = route_table_id_and_network_cidr[1]
  }]

  two_tgw_new_vpc_routes_to_seven_tgw_vpcs = {
    for this in local.two_vpc_routes_to_seven_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_routes_to_seven_tgw_vpcs" {
  provider = aws.two

  for_each = local.two_tgw_new_vpc_routes_to_seven_tgw_vpcs

  transit_gateway_id     = local.two_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  two_vpc_routes_to_eight_tgw_vpcs = [
    for route_table_id_and_network_cidr in setproduct(local.two_tgw_vpc_route_table_ids, local.eight_tgw_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_network_cidr[0]
      destination_cidr_block = route_table_id_and_network_cidr[1]
  }]

  two_tgw_new_vpc_routes_to_eight_tgw_vpcs = {
    for this in local.two_vpc_routes_to_eight_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_routes_to_eight_tgw_vpcs" {
  provider = aws.two

  for_each = local.two_tgw_new_vpc_routes_to_eight_tgw_vpcs

  transit_gateway_id     = local.two_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  two_vpc_routes_to_nine_tgw_vpcs = [
    for route_table_id_and_network_cidr in setproduct(local.two_tgw_vpc_route_table_ids, local.nine_tgw_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_network_cidr[0]
      destination_cidr_block = route_table_id_and_network_cidr[1]
  }]

  two_tgw_new_vpc_routes_to_nine_tgw_vpcs = {
    for this in local.two_vpc_routes_to_nine_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_routes_to_nine_tgw_vpcs" {
  provider = aws.two

  for_each = local.two_tgw_new_vpc_routes_to_nine_tgw_vpcs

  transit_gateway_id     = local.two_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  two_vpc_routes_to_ten_tgw_vpcs = [
    for route_table_id_and_network_cidr in setproduct(local.two_tgw_vpc_route_table_ids, local.ten_tgw_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_network_cidr[0]
      destination_cidr_block = route_table_id_and_network_cidr[1]
  }]

  two_tgw_new_vpc_routes_to_ten_tgw_vpcs = {
    for this in local.two_vpc_routes_to_ten_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_routes_to_ten_tgw_vpcs" {
  provider = aws.two

  for_each = local.two_tgw_new_vpc_routes_to_ten_tgw_vpcs

  transit_gateway_id     = local.two_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

