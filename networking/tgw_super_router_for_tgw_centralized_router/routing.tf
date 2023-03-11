locals {
  local_tgws_all_vpc_network_cidrs              = flatten(local.local_tgws[*].vpc.network_cidrs)
  local_tgws_all_vpc_routes                     = flatten(local.local_tgws[*].vpc.routes)
  local_tgws_all_current_local_only_vpc_routes  = flatten(local.local_tgws[*].vpc.current_local_only_routes)
  local_tgws_all_vpc_routes_route_table_ids     = local.local_tgws_all_vpc_routes[*].route_table_id
  local_tgws_all_vpc_routes_transit_gateway_ids = local.local_tgws_all_vpc_routes[*].transit_gateway_id
  local_tgws_all_route_table_ids                = local.local_tgws[*].route_table_id
  local_tgws_all_ids                            = local.local_tgws[*].id

  peer_tgws_all_vpc_network_cidrs              = flatten(local.peer_tgws[*].vpc.network_cidrs)
  peer_tgws_all_vpc_routes                     = flatten(local.peer_tgws[*].vpc.routes)
  peer_tgws_all_current_local_only_vpc_routes  = flatten(local.peer_tgws[*].vpc.current_local_only_routes)
  peer_tgws_all_vpc_routes_route_table_ids     = local.peer_tgws_all_vpc_routes[*].route_table_id
  peer_tgws_all_vpc_routes_transit_gateway_ids = local.peer_tgws_all_vpc_routes[*].transit_gateway_id
  peer_tgws_all_route_table_ids                = local.peer_tgws[*].route_table_id
  peer_tgws_all_ids                            = local.peer_tgws[*].id

  route_format = "%s|%s"
}

########################################################################################
# Begin Local Centralized Router Side
#########################################################################################

# one route table for all local network_cidrs
resource "aws_ec2_transit_gateway_route_table" "this_local" {
  provider = aws.local

  transit_gateway_id = aws_ec2_transit_gateway.this_local.id
  tags = merge(
    local.default_tags,
    { Name = local.local_super_router_name }
  )
}

locals {
  local_vpc_network_cidr_to_local_tgw = merge([
    for this in local.local_tgws : {
      for vpc_network_cidr in this.vpc.network_cidrs :
      vpc_network_cidr => this
  }]...)
}

# add all local tgw routes to local tgw super router
resource "aws_ec2_transit_gateway_route" "this_local" {
  provider = aws.local

  for_each = local.local_vpc_network_cidr_to_local_tgw

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.this_local_to_locals, each.value.id).id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals]
}

# associate all local tgw routes table to local tgw super router route tables
resource "aws_ec2_transit_gateway_route_table_association" "this_local" {
  provider = aws.local

  for_each = local.local_tgw_id_to_local_tgw

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.this_local_to_locals, each.key).id

  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals]
}

# associate local tgw route table to local attachment accepters
resource "aws_ec2_transit_gateway_route_table_association" "this_local_to_locals" {
  provider = aws.local

  for_each = local.local_tgw_id_to_local_tgw

  transit_gateway_route_table_id = each.value.route_table_id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals, each.key).id

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

# You cannot propagate a tgw peering attachment to a Transit Gateway Route Table
# resource "aws_ec2_transit_gateway_route_table_propagation" "this_local" {}

locals {
  # keep track of current rtb-id to tgw-id
  local_tgw_all_vpc_route_table_id_to_local_all_vpc_tgw_id = zipmap(local.local_tgws_all_vpc_routes_route_table_ids, local.local_tgws_all_vpc_routes_transit_gateway_ids)

  # build new local vpc routes to other peer tgws
  local_vpc_routes_to_peer_tgws = [
    for route_table_id_and_peer_tgw_network_cidr in setproduct(local.local_tgws_all_vpc_routes_route_table_ids, local.peer_tgws_all_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_peer_tgw_network_cidr[0]
      destination_cidr_block = route_table_id_and_peer_tgw_network_cidr[1]
  }]

  local_tgw_all_new_vpc_routes_to_peer_tgws = {
    for this in local.local_vpc_routes_to_peer_tgws :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_local_vpc_routes_to_peer_tgws" {
  provider = aws.local

  for_each = local.local_tgw_all_new_vpc_routes_to_peer_tgws

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = lookup(local.local_tgw_all_vpc_route_table_id_to_local_all_vpc_tgw_id, each.value.route_table_id)
}

locals {
  # build new local vpc routes to other local vpcs
  local_vpc_routes_to_local_tgws = [
    for route_table_id_and_local_tgw_network_cidr in setproduct(local.local_tgws_all_vpc_routes_route_table_ids, local.local_tgws_all_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_local_tgw_network_cidr[0]
      destination_cidr_block = route_table_id_and_local_tgw_network_cidr[1]
  }]

  # subtract all current existing local vpc routes from all local vpc routes
  local_tgw_all_new_vpc_routes_to_local_vpcs = {
    for this in setsubtract(local.local_vpc_routes_to_local_tgws, local.local_tgws_all_current_local_only_vpc_routes) :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_local_vpcs_routes_to_local_vpcs" {
  provider = aws.local

  for_each = local.local_tgw_all_new_vpc_routes_to_local_vpcs

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = lookup(local.local_tgw_all_vpc_route_table_id_to_local_all_vpc_tgw_id, each.value.route_table_id)
}

locals {
  local_tgw_route_table_id_to_local_tgw_id = zipmap(local.local_tgws_all_route_table_ids, local.local_tgws_all_ids)

  # build new local tgw routes to other peer tgws
  local_tgw_routes_to_peer_tgws = [
    for route_table_id_and_peer_tgw_network_cidr in setproduct(local.local_tgws_all_route_table_ids, local.peer_tgws_all_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_peer_tgw_network_cidr[0]
      destination_cidr_block = route_table_id_and_peer_tgw_network_cidr[1]
  }]

  local_tgw_all_new_tgw_routes_to_vpcs_in_peer_tgws = {
    for this in local.local_tgw_routes_to_peer_tgws :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_ec2_transit_gateway_route" "this_local_tgw_routes_to_vpcs_in_peer_tgws" {
  provider = aws.local

  for_each = local.local_tgw_all_new_tgw_routes_to_vpcs_in_peer_tgws

  transit_gateway_route_table_id = each.value.route_table_id
  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals, lookup(local.local_tgw_route_table_id_to_local_tgw_id, each.value.route_table_id)).id

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

locals {
  # build new local tgw routes to other local tgws
  local_tgws_routes_to_local_tgws = [
    for route_table_id_and_network_cidr in setproduct(local.local_tgws_all_route_table_ids, local.local_tgws_all_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_network_cidr[0]
      destination_cidr_block = route_table_id_and_network_cidr[1]
  }]

  # generate current existing local tgw routes for its local vpcs
  local_current_tgw_routes = flatten([
    for this in local.local_tgws : [
      for route_table_id_and_network_cidr in setproduct([this.route_table_id], this.vpc.network_cidrs) : {
        route_table_id         = route_table_id_and_network_cidr[0]
        destination_cidr_block = route_table_id_and_network_cidr[1]
  }]])

  # subtract current existing local tgw routes from all local tgw routes
  local_tgw_all_new_tgw_routes_to_local_tgws = {
    for this in setsubtract(local.local_tgws_routes_to_local_tgws, local.local_current_tgw_routes) :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_ec2_transit_gateway_route" "this_local_tgw_routes_to_local_tgws" {
  provider = aws.local

  for_each = local.local_tgw_all_new_tgw_routes_to_local_tgws

  transit_gateway_route_table_id = each.value.route_table_id
  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals, lookup(local.local_tgw_route_table_id_to_local_tgw_id, each.value.route_table_id)).id
}

########################################################################################
# Begin Peer Centralized Router Side
#########################################################################################

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

# add all local tgw routes to local tgw super router
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
  # keep track of current rtb-id to tgw-id
  peer_tgw_all_vpc_route_table_id_to_peer_all_vpc_tgw_id = zipmap(local.peer_tgws_all_vpc_routes_route_table_ids, local.peer_tgws_all_vpc_routes_transit_gateway_ids)

  # build new peer vpc routes to other local tgws
  peer_vpc_routes_to_local_tgws = [
    for route_table_id_and_peer_tgw_network_cidr in setproduct(local.peer_tgws_all_vpc_routes_route_table_ids, local.local_tgws_all_vpc_network_cidrs) : {
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
  transit_gateway_id     = lookup(local.peer_tgw_all_vpc_route_table_id_to_peer_all_vpc_tgw_id, each.value.route_table_id)
}

locals {
  # build new peer vpc routes to other peer vpcs
  peer_vpc_routes_to_peer_tgws = [
    for route_table_id_and_peer_tgw_network_cidr in setproduct(local.peer_tgws_all_vpc_routes_route_table_ids, local.peer_tgws_all_vpc_network_cidrs) : {
      route_table_id         = route_table_id_and_peer_tgw_network_cidr[0]
      destination_cidr_block = route_table_id_and_peer_tgw_network_cidr[1]
  }]

  # subtract current existing local vpc routes from all local vpc routes
  peer_tgw_all_new_vpc_routes_to_peer_vpcs = {
    for this in setsubtract(local.peer_vpc_routes_to_peer_tgws, local.peer_tgws_all_current_local_only_vpc_routes) :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_peer_vpcs_routes_to_peer_vpcs" {
  provider = aws.peer

  for_each = local.peer_tgw_all_new_vpc_routes_to_peer_vpcs

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = lookup(local.peer_tgw_all_vpc_route_table_id_to_peer_all_vpc_tgw_id, each.value.route_table_id)
}

locals {
  peer_tgw_route_table_id_to_peer_tgw_id = zipmap(local.peer_tgws_all_route_table_ids, local.peer_tgws_all_ids)

  # build new peer tgw routes to other peer tgws
  peer_tgw_routes_to_local_tgws = [
    for route_table_id_and_peer_tgw_network_cidr in setproduct(local.peer_tgws_all_route_table_ids, local.local_tgws_all_vpc_network_cidrs) : {
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

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

locals {
  # build new peer tgw routes to other peer tgws
  peer_tgws_routes_to_peer_tgws = [
    for route_table_id_and_network_cidr in setproduct(local.peer_tgws_all_route_table_ids, local.peer_tgws_all_vpc_network_cidrs) : {
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

########################################################################################
# Begin Local Super Router Side
#########################################################################################

# add all peer tgw routes to local tgw super router
resource "aws_ec2_transit_gateway_route" "this_local_to_peer_tgws" {
  provider = aws.local

  for_each = local.peer_vpc_network_cidr_to_peer_tgw

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this_local_to_this_peer.id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_this_peer]
}

# associate local tgw route table to super router peering attachment
resource "aws_ec2_transit_gateway_route_table_association" "this_local_to_this_peer" {
  provider = aws.local

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this_local_to_this_peer.id

  # make sure the peer links are up before associating the route the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_this_peer]
}

########################################################################################
# Begin Peer Super Router Side
#########################################################################################

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
