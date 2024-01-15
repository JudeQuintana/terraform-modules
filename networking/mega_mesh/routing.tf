locals {
  route_format = "%s|%s"

  one_tgw_vpc_network_cidrs          = local.one_tgw.vpc.network_cidrs
  one_tgw_vpc_routes_route_table_ids = local.one_tgw.vpc.routes[*].route_table_id

  two_tgw_vpc_network_cidrs          = local.two_tgw.vpc.network_cidrs
  two_tgw_vpc_routes_route_table_ids = local.two_tgw.vpc.routes[*].route_table_id

  three_tgw_vpc_network_cidrs          = local.three_tgw.vpc.network_cidrs
  three_tgw_vpc_routes_route_table_ids = local.three_tgw.vpc.routes[*].route_table_id

  four_tgw_vpc_network_cidrs          = local.four_tgw.vpc.network_cidrs
  four_tgw_vpc_routes_route_table_ids = local.four_tgw.vpc.routes[*].route_table_id

  five_tgw_vpc_network_cidrs          = local.five_tgw.vpc.network_cidrs
  five_tgw_vpc_routes_route_table_ids = local.five_tgw.vpc.routes[*].route_table_id
}

## vpc routes
# one
locals {
  # build new one vpc routes to two tgw vpcs
  one_vpc_routes_to_two_tgw_vpcs = [
    for one_route_table_id_and_two_tgw_network_cidr in setproduct(local.one_tgw_vpc_routes_route_table_ids, local.two_tgw_vpc_network_cidrs) : {
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

  transit_gateway_id     = local.one_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  one_vpc_routes_to_three_tgw_vpcs = [
    for one_route_table_id_and_two_tgw_network_cidr in setproduct(local.one_tgw_vpc_routes_route_table_ids, local.three_tgw_vpc_network_cidrs) : {
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

  transit_gateway_id     = local.one_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

# two
locals {
  # build new two vpc routes to one tgw vpcs
  two_vpc_routes_to_one_tgw_vpcs = [
    for two_route_table_id_and_one_tgw_network_cidr in setproduct(local.two_tgw_vpc_routes_route_table_ids, local.one_tgw_vpc_network_cidrs) : {
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

  transit_gateway_id     = local.two_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  two_vpc_routes_to_three_tgw_vpcs = [
    for two_route_table_id_and_three_tgw_network_cidr in setproduct(local.two_tgw_vpc_routes_route_table_ids, local.three_tgw_vpc_network_cidrs) : {
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

  transit_gateway_id     = local.two_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

# three
locals {
  # build new three vpc routes to one tgw vpcs
  three_vpc_routes_to_one_tgw_vpcs = [
    for three_route_table_id_and_one_tgw_network_cidr in setproduct(local.three_tgw_vpc_routes_route_table_ids, local.one_tgw_vpc_network_cidrs) : {
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

  transit_gateway_id     = local.three_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  three_vpc_routes_to_two_tgw_vpcs = [
    for three_route_table_id_and_two_tgw_network_cidr in setproduct(local.three_tgw_vpc_routes_route_table_ids, local.two_tgw_vpc_network_cidrs) : {
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

  transit_gateway_id     = local.three_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

# four
locals {
  # build new four vpc routes to one tgw vpcs
  four_vpc_routes_to_one_tgw_vpcs = [
    for four_route_table_id_and_one_tgw_network_cidr in setproduct(local.four_tgw_vpc_routes_route_table_ids, local.one_tgw_vpc_network_cidrs) : {
      route_table_id         = four_route_table_id_and_one_tgw_network_cidr[0]
      destination_cidr_block = four_route_table_id_and_one_tgw_network_cidr[1]
  }]

  four_tgw_new_vpc_routes_to_one_tgw_vpcs = {
    for this in local.four_vpc_routes_to_one_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_four_vpc_routes_to_one_tgw_vpcs" {
  provider = aws.four

  for_each = local.four_tgw_new_vpc_routes_to_one_tgw_vpcs

  transit_gateway_id     = local.four_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  # build new four vpc routes to two tgw vpcs
  four_vpc_routes_to_two_tgw_vpcs = [
    for four_route_table_id_and_two_tgw_network_cidr in setproduct(local.four_tgw_vpc_routes_route_table_ids, local.two_tgw_vpc_network_cidrs) : {
      route_table_id         = four_route_table_id_and_two_tgw_network_cidr[0]
      destination_cidr_block = four_route_table_id_and_two_tgw_network_cidr[1]
  }]

  four_tgw_new_vpc_routes_to_two_tgw_vpcs = {
    for this in local.four_vpc_routes_to_two_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_four_vpc_routes_to_two_tgw_vpcs" {
  provider = aws.four

  for_each = local.four_tgw_new_vpc_routes_to_two_tgw_vpcs

  transit_gateway_id     = local.four_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

locals {
  # build new four vpc routes to three tgw vpcs
  four_vpc_routes_to_three_tgw_vpcs = [
    for four_route_table_id_and_three_tgw_network_cidr in setproduct(local.four_tgw_vpc_routes_route_table_ids, local.three_tgw_vpc_network_cidrs) : {
      route_table_id         = four_route_table_id_and_three_tgw_network_cidr[0]
      destination_cidr_block = four_route_table_id_and_three_tgw_network_cidr[1]
  }]

  four_tgw_new_vpc_routes_to_three_tgw_vpcs = {
    for this in local.four_vpc_routes_to_three_tgw_vpcs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_four_vpc_routes_to_three_tgw_vpcs" {
  provider = aws.four

  for_each = local.four_tgw_new_vpc_routes_to_three_tgw_vpcs

  transit_gateway_id     = local.four_tgw.id
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
}

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

## tgw mesh routes
# one
resource "aws_ec2_transit_gateway_route" "this_one_tgw_routes_to_vpcs_in_two_tgw" {
  provider = aws.one

  for_each = toset(local.two_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.one_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_one_to_this_two.id
}

resource "aws_ec2_transit_gateway_route" "this_one_tgw_routes_to_vpcs_in_three_tgw" {
  provider = aws.one

  for_each = toset(local.three_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.one_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_three_to_this_one.id
}

# two
resource "aws_ec2_transit_gateway_route" "this_two_tgw_routes_to_vpcs_in_one_tgw" {
  provider = aws.two

  for_each = toset(local.one_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_one_to_this_two.id
}

resource "aws_ec2_transit_gateway_route" "this_two_tgw_routes_to_vpcs_in_three_tgw" {
  provider = aws.two

  for_each = toset(local.three_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
}

# three
resource "aws_ec2_transit_gateway_route" "this_three_tgw_routes_to_vpcs_in_one_tgw" {
  provider = aws.three

  for_each = toset(local.one_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_three_to_this_one.id
}

resource "aws_ec2_transit_gateway_route" "this_three_tgw_routes_to_vpcs_in_two_tgw" {
  provider = aws.three

  for_each = toset(local.two_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
}

# four
resource "aws_ec2_transit_gateway_route" "this_four_tgw_routes_to_vpcs_in_one_tgw" {
  provider = aws.four

  for_each = toset(local.one_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_four_to_this_one.id
}

resource "aws_ec2_transit_gateway_route" "this_four_tgw_routes_to_vpcs_in_two_tgw" {
  provider = aws.four

  for_each = toset(local.two_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_four_to_this_two.id
}

resource "aws_ec2_transit_gateway_route" "this_four_tgw_routes_to_vpcs_in_three_tgw" {
  provider = aws.four

  for_each = toset(local.three_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_four_to_this_three.id
}

# five
resource "aws_ec2_transit_gateway_route" "this_five_tgw_routes_to_vpcs_in_one_tgw" {
  provider = aws.five

  for_each = toset(local.one_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_one.id
}

resource "aws_ec2_transit_gateway_route" "this_five_tgw_routes_to_vpcs_in_two_tgw" {
  provider = aws.five

  for_each = toset(local.two_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_two.id
}

resource "aws_ec2_transit_gateway_route" "this_five_tgw_routes_to_vpcs_in_three_tgw" {
  provider = aws.five

  for_each = toset(local.three_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_three.id
}

resource "aws_ec2_transit_gateway_route" "this_five_tgw_routes_to_vpcs_in_four_tgw" {
  provider = aws.five

  for_each = toset(local.four_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_four.id
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

# two
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

# four
resource "aws_ec2_transit_gateway_route_table_association" "this_four_to_this_one" {
  provider = aws.four

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_four_to_this_one.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_four_to_this_two" {
  provider = aws.four

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_four_to_this_two.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_four_to_this_three" {
  provider = aws.four

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_four_to_this_three.id
}

# five
resource "aws_ec2_transit_gateway_route_table_association" "this_five_to_this_one" {
  provider = aws.five

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_one.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_five_to_this_two" {
  provider = aws.five

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_two.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_five_to_this_three" {
  provider = aws.five

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_three.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_five_to_this_four" {
  provider = aws.five

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_four.id
}
