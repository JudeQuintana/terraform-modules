locals {
  peer_tgws_vpc_route_table_ids_with_tgw_id = [
    for this in local.peer_tgws : {
      route_table_ids    = concat(this.vpc.private_route_table_ids, this.vpc.public_route_table_ids)
      transit_gateway_id = this.id
  }]

  # keep track of current rtb-id to tgw-id
  peer_tgws_vpc_route_table_id_to_tgw_id = merge([
    for this in local.peer_tgws_vpc_route_table_ids_with_tgw_id : {
      for route_table_id in this.route_table_ids :
      route_table_id => this.transit_gateway_id
  }]...)

  peer_tgws_vpc_tgw_id_to_route_table_ids = {
    for this in local.peer_tgws_vpc_route_table_ids_with_tgw_id :
    this.transit_gateway_id => this.route_table_ids
  }

  peer_tgws_vpc_network_cidrs   = flatten(concat(local.peer_tgws[*].vpc.network_cidrs, local.peer_tgws[*].vpc.secondary_cidrs))
  peer_tgws_vpc_route_table_ids = flatten(local.peer_tgws_vpc_route_table_ids_with_tgw_id[*].route_table_ids)
  peer_tgws_route_table_ids     = local.peer_tgws[*].route_table_id
  peer_tgws_ids                 = local.peer_tgws[*].id
}

# one route table for all peer network_cidrs
resource "aws_ec2_transit_gateway_route_table" "this_peer" {
  provider = aws.peer

  transit_gateway_id = aws_ec2_transit_gateway.this_peer.id
  tags = merge(
    local.default_tags,
    { Name = local.peer_super_router_name }
  )
}

locals {
  peer_vpc_network_cidr_to_peer_tgw = merge([
    for this in local.peer_tgws : {
      for vpc_network_cidr in this.vpc.network_cidrs :
      vpc_network_cidr => this
  }]...)
}

# add all peer tgw routes to peer tgw super router
resource "aws_ec2_transit_gateway_route" "this_peer" {
  provider = aws.peer

  for_each = local.peer_vpc_network_cidr_to_peer_tgw

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_peer.id
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.this_peer_to_peers, each.value.id).id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_peers]
}

# associate all peer tgw routes table to peer tgw super router route table
resource "aws_ec2_transit_gateway_route_table_association" "this_peer" {
  provider = aws.peer

  for_each = local.peer_tgw_id_to_peer_tgw

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_peer.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.this_peer_to_peers, each.key).id

  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_peers]
}

# associate peer tgw route table to peer attachment accepters
resource "aws_ec2_transit_gateway_route_table_association" "this_peer_to_peers" {
  provider = aws.peer

  for_each = local.peer_tgw_id_to_peer_tgw

  transit_gateway_route_table_id = each.value.route_table_id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_peers, each.key).id

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

# You cannot propagate a tgw peering attachment to a Transit Gateway Route Table
# resource "aws_ec2_transit_gateway_route_table_propagation" "this_peer" {}

locals {
  # build new peer vpc routes to other local tgws
  peer_vpc_routes_to_local_tgws = [
    for route_table_id_and_peer_tgw_network_cidr in setproduct(local.peer_tgws_vpc_route_table_ids, local.local_tgws_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_peer_tgw_network_cidr[0]
      destination_cidr_block = route_table_id_and_peer_tgw_network_cidr[1]
  }]

  peer_tgw_all_new_vpc_routes_to_local_tgws = {
    for this in local.peer_vpc_routes_to_local_tgws :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_peer_vpc_routes_to_local_tgws" {
  provider = aws.peer

  for_each = local.peer_tgw_all_new_vpc_routes_to_local_tgws

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = lookup(local.peer_tgws_vpc_route_table_id_to_tgw_id, each.value.route_table_id)
}

locals {
  # build new peer vpc routes to other peer vpcs
  peer_vpc_routes_to_peer_tgws = [
    for route_table_id_and_peer_tgw_network_cidr in setproduct(local.peer_tgws_vpc_route_table_ids, local.peer_tgws_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_peer_tgw_network_cidr[0]
      destination_cidr_block = route_table_id_and_peer_tgw_network_cidr[1]
  }]

  # generate current existing peer vpc routes
  peer_current_vpc_routes = flatten([
    for this in local.peer_tgws : [
      for route_table_id_and_vpc_network_cidr in setproduct(lookup(local.peer_tgws_vpc_tgw_id_to_route_table_ids, this.id), this.vpc.network_cidrs) : {
        route_table_id         = route_table_id_and_vpc_network_cidr[0]
        destination_cidr_block = route_table_id_and_vpc_network_cidr[1]
  }]])

  # subtract current existing peer vpc routes from all peer vpc routes
  peer_tgw_all_new_vpc_routes_to_peer_vpcs = {
    for this in setsubtract(local.peer_vpc_routes_to_peer_tgws, local.peer_current_vpc_routes) :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_peer_vpcs_routes_to_peer_vpcs" {
  provider = aws.peer

  for_each = local.peer_tgw_all_new_vpc_routes_to_peer_vpcs

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = lookup(local.peer_tgws_vpc_route_table_id_to_tgw_id, each.value.route_table_id)
}

locals {
  peer_tgw_route_table_id_to_peer_tgw_id = zipmap(local.peer_tgws_route_table_ids, local.peer_tgws_ids)

  # build new peer tgw routes to other peer tgws
  peer_tgw_routes_to_local_tgws = [
    for route_table_id_and_peer_tgw_network_cidr in setproduct(local.peer_tgws_route_table_ids, local.local_tgws_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_peer_tgw_network_cidr[0]
      destination_cidr_block = route_table_id_and_peer_tgw_network_cidr[1]
  }]

  peer_tgw_all_new_tgw_routes_to_vpcs_in_local_tgws = {
    for this in local.peer_tgw_routes_to_local_tgws :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_ec2_transit_gateway_route" "this_peer_tgw_routes_to_vpcs_in_peer_tgws" {
  provider = aws.peer

  for_each = local.peer_tgw_all_new_tgw_routes_to_vpcs_in_local_tgws

  transit_gateway_route_table_id = each.value.route_table_id
  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_peers, lookup(local.peer_tgw_route_table_id_to_peer_tgw_id, each.value.route_table_id)).id
}

locals {
  # build new peer tgw routes to other peer tgws
  peer_tgws_routes_to_peer_tgws = [
    for route_table_id_and_network_cidr in setproduct(local.peer_tgws_route_table_ids, local.peer_tgws_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_network_cidr[0]
      destination_cidr_block = route_table_id_and_network_cidr[1]
  }]

  # generate current existing peer tgw routes for its peer vpcs
  peer_current_tgw_routes = flatten([
    for this in local.peer_tgws : [
      for route_table_id_and_network_cidr in setproduct([this.route_table_id], this.vpc.network_cidrs) : {
        route_table_id         = route_table_id_and_network_cidr[0]
        destination_cidr_block = route_table_id_and_network_cidr[1]
  }]])

  # subtract current existing peer tgw routes from all peer tgw routes
  peer_tgw_all_new_tgw_routes_to_peer_tgws = {
    for this in setsubtract(local.peer_tgws_routes_to_peer_tgws, local.peer_current_tgw_routes) :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_ec2_transit_gateway_route" "this_peer_tgw_routes_to_peer_tgws" {
  provider = aws.peer

  for_each = local.peer_tgw_all_new_tgw_routes_to_peer_tgws

  transit_gateway_route_table_id = each.value.route_table_id
  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_peers, lookup(local.peer_tgw_route_table_id_to_peer_tgw_id, each.value.route_table_id)).id
}

# add all local tgw routes to peer tgw super router
resource "aws_ec2_transit_gateway_route" "this_peer_to_local_tgws" {
  provider = aws.peer

  for_each = local.local_vpc_network_cidr_to_local_tgw

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_peer.id
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this_local_to_this_peer.id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_this_peer]
}

# associate peer tgw route table to super router peering attachment
resource "aws_ec2_transit_gateway_route_table_association" "this_peer_to_this_local" {
  provider = aws.peer

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_peer.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this_local_to_this_peer.id

  # make sure the peer links are up before associating the route the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_this_peer]
}
