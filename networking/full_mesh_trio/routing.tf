locals {
  route_format = "%s|%s"

  one_tgws_all_vpc_network_cidrs          = local.one_tgw.vpc.network_cidrs
  one_tgws_all_vpc_routes                 = local.one_tgw.vpc.routes
  one_tgws_all_vpc_routes_route_table_ids = local.one_tgws_all_vpc_routes[*].route_table_id

  two_tgws_all_vpc_network_cidrs          = local.two_tgw.vpc.network_cidrs
  two_tgws_all_vpc_routes                 = local.two_tgw.vpc.routes
  two_tgws_all_vpc_routes_route_table_ids = local.two_tgws_all_vpc_routes[*].route_table_id

  three_tgws_all_vpc_network_cidrs          = local.three_tgw.vpc.network_cidrs
  three_tgws_all_vpc_routes                 = local.three_tgw.vpc.routes
  three_tgws_all_vpc_routes_route_table_ids = local.three_tgws_all_vpc_routes[*].route_table_id
}

locals {
  # build new one vpc routes to two tgws
  one_vpc_routes_to_two_tgws = [
    for route_table_id_and_two_tgw_network_cidr in setproduct(local.one_tgws_all_vpc_routes_route_table_ids, local.two_tgws_all_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_two_tgw_network_cidr[0]
      destination_cidr_block = route_table_id_and_two_tgw_network_cidr[1]
  }]

  one_tgw_all_new_vpc_routes_to_two_tgws = {
    for this in local.one_vpc_routes_to_two_tgws :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_one_vpc_routes_to_two_tgws" {
  provider = aws.one

  for_each = local.one_tgw_all_new_vpc_routes_to_two_tgws

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = local.one_tgw.id
}

locals {
  one_vpc_routes_to_three_tgws = [
    for route_table_id_and_two_tgw_network_cidr in setproduct(local.one_tgws_all_vpc_routes_route_table_ids, local.three_tgws_all_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_two_tgw_network_cidr[0]
      destination_cidr_block = route_table_id_and_two_tgw_network_cidr[1]
  }]

  one_tgw_all_new_vpc_routes_to_three_tgws = {
    for this in local.one_vpc_routes_to_three_tgws :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_one_vpc_routes_to_three_tgws" {
  provider = aws.one

  for_each = local.one_tgw_all_new_vpc_routes_to_three_tgws

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = local.one_tgw.id
}

locals {
  # build new two vpc routes to one tgws
  two_vpc_routes_to_one_tgws = [
    for route_table_id_and_one_tgw_network_cidr in setproduct(local.two_tgws_all_vpc_routes_route_table_ids, local.one_tgws_all_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_one_tgw_network_cidr[0]
      destination_cidr_block = route_table_id_and_one_tgw_network_cidr[1]
  }]

  two_tgw_all_new_vpc_routes_to_one_tgws = {
    for this in local.two_vpc_routes_to_one_tgws :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_routes_to_one_tgws" {
  provider = aws.two

  for_each = local.two_tgw_all_new_vpc_routes_to_one_tgws

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = local.two_tgw.id
}

locals {
  two_vpc_routes_to_three_tgws = [
    for route_table_id_and_three_tgw_network_cidr in setproduct(local.two_tgws_all_vpc_routes_route_table_ids, local.three_tgws_all_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_three_tgw_network_cidr[0]
      destination_cidr_block = route_table_id_and_three_tgw_network_cidr[1]
  }]

  two_tgw_all_new_vpc_routes_to_three_tgws = {
    for this in local.two_vpc_routes_to_three_tgws :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_two_vpc_routes_to_three_tgws" {
  provider = aws.two

  for_each = local.two_tgw_all_new_vpc_routes_to_three_tgws

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = local.two_tgw.id
}

locals {
  # build new three vpc routes to one tgws
  three_vpc_routes_to_one_tgws = [
    for route_table_id_and_one_tgw_network_cidr in setproduct(local.three_tgws_all_vpc_routes_route_table_ids, local.one_tgws_all_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_one_tgw_network_cidr[0]
      destination_cidr_block = route_table_id_and_one_tgw_network_cidr[1]
  }]

  three_tgw_all_new_vpc_routes_to_one_tgws = {
    for this in local.three_vpc_routes_to_one_tgws :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_three_vpc_routes_to_one_tgws" {
  provider = aws.three

  for_each = local.three_tgw_all_new_vpc_routes_to_one_tgws

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = local.three_tgw.id
}

locals {
  three_vpc_routes_to_two_tgws = [
    for route_table_id_and_two_tgw_network_cidr in setproduct(local.three_tgws_all_vpc_routes_route_table_ids, local.two_tgws_all_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_two_tgw_network_cidr[0]
      destination_cidr_block = route_table_id_and_two_tgw_network_cidr[1]
  }]

  three_tgw_all_new_vpc_routes_to_two_tgws = {
    for this in local.three_vpc_routes_to_two_tgws :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_three_vpc_routes_to_two_tgws" {
  provider = aws.three

  for_each = local.three_tgw_all_new_vpc_routes_to_two_tgws

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = local.three_tgw.id
}

# TGWs mesh Routes
#one
resource "aws_ec2_transit_gateway_route" "this_one_tgw_routes_to_vpcs_in_two_tgws" {
  provider = aws.one

  for_each = toset(local.two_tgws_all_vpc_network_cidrs)

  transit_gateway_route_table_id = local.one_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_one_to_this_two.id
}

resource "aws_ec2_transit_gateway_route" "this_one_tgw_routes_to_vpcs_in_three_tgws" {
  provider = aws.one

  for_each = toset(local.three_tgws_all_vpc_network_cidrs)

  transit_gateway_route_table_id = local.one_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_three_to_this_one.id
}

#two
resource "aws_ec2_transit_gateway_route" "this_two_tgw_routes_to_vpcs_in_one_tgws" {
  provider = aws.two

  for_each = toset(local.one_tgws_all_vpc_network_cidrs)

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_one_to_this_two.id
}

resource "aws_ec2_transit_gateway_route" "this_two_tgw_routes_to_vpcs_in_three_tgws" {
  provider = aws.two

  for_each = toset(local.three_tgws_all_vpc_network_cidrs)

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
}

# three
resource "aws_ec2_transit_gateway_route" "this_three_tgw_routes_to_vpcs_in_one_tgws" {
  provider = aws.three

  for_each = toset(local.one_tgws_all_vpc_network_cidrs)

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_three_to_this_one.id
}

resource "aws_ec2_transit_gateway_route" "this_three_tgw_routes_to_vpcs_in_two_tgws" {
  provider = aws.three

  for_each = toset(local.two_tgws_all_vpc_network_cidrs)

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
}

## Associations
# one
resource "aws_ec2_transit_gateway_route_table_association" "this_one_to_this_two" {
  provider = aws.one

  transit_gateway_route_table_id = local.one_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_one_to_this_two.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_one_to_this_three" {
  provider = aws.one

  transit_gateway_route_table_id = local.one_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_three_to_this_one.id
}

#two
resource "aws_ec2_transit_gateway_route_table_association" "this_two_to_this_one" {
  provider = aws.two

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_one_to_this_two.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_two_to_this_three" {
  provider = aws.two

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
}

# three
resource "aws_ec2_transit_gateway_route_table_association" "this_three_to_this_one" {
  provider = aws.three

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_three_to_this_one.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_three_to_this_two" {
  provider = aws.three

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
}
