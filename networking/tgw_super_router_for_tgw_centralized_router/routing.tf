locals {
  local_tgws_all_vpc_networks = flatten(local.local_tgws[*].networks)
  local_tgws_all_vpc_routes   = flatten(local.local_tgws[*].vpc_routes)
  peer_tgws_all_vpc_networks  = flatten(local.peer_tgws[*].networks)
  peer_tgws_all_vpc_routes    = flatten(local.peer_tgws[*].vpc_routes)
  route_format                = "%s|%s"
}

########################################################################################
# Begin Local Side
########################################################################################

# one route table for all networks
resource "aws_ec2_transit_gateway_route_table" "this_local" {
  provider = aws.local

  transit_gateway_id = aws_ec2_transit_gateway.this_local.id
  tags = merge(
    local.default_tags,
    { Name = local.super_router_name }
  )
}

locals {
  local_vpc_network_to_local_tgw = merge(
    [for this in local.local_tgws :
      { for vpc_name, vpc in this.vpcs :
        vpc.network => this
  }]...)
}

# add all local tgw routes to local tgw super router
resource "aws_ec2_transit_gateway_route" "this_local" {
  provider = aws.local

  for_each = local.local_vpc_network_to_local_tgw

  destination_cidr_block         = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.this_local_to_locals, each.value.id).id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals]
}

# associate all local tgw routes table associations to local tgw super router
resource "aws_ec2_transit_gateway_route_table_association" "this_local" {
  provider = aws.local

  for_each = toset(local.local_tgws[*].id)

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.this_local_to_locals, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id

  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals]
}

# associate local tgw route table to accociated local attachment accepters
resource "aws_ec2_transit_gateway_route_table_association" "this_local_to_locals" {
  provider = aws.local

  for_each = local.local_tgw_id_to_local_tgw

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals, each.key).id
  transit_gateway_route_table_id = each.value.route_table_id

  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment.this_local_to_locals]

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

# You cannot propagate a tgw peering attachment to a Transit Gateway Route Table
# resource "aws_ec2_transit_gateway_route_table_propagation" "this_local" {}

locals {
  # generate routes for local vpcs in other peer tgws
  # keep track of current rtb-id to tgw-id
  local_tgw_rtb_id_to_local_tgw_id = zipmap(local.local_tgws_all_vpc_routes[*].route_table_id, local.local_tgws_all_vpc_routes[*].transit_gateway_id)

  # build new local vpc routes to other peer tgws
  local_vpc_routes_to_other_peer_tgws = [
    for rtb_id_and_peer_tgw_networks in setproduct(local.local_tgws_all_vpc_routes[*].route_table_id, local.peer_tgws_all_vpc_networks) : {
      destination_cidr_block = rtb_id_and_peer_tgw_networks[1]
      route_table_id         = rtb_id_and_peer_tgw_networks[0]
  }]

  local_tgw_all_new_vpc_routes_to_peer_tgws = {
    for this in local.local_vpc_routes_to_other_peer_tgws :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_local_vpc_routes_to_peer_tgws" {
  provider = aws.local

  for_each = local.local_tgw_all_new_vpc_routes_to_peer_tgws

  destination_cidr_block = each.value.destination_cidr_block
  route_table_id         = each.value.route_table_id
  transit_gateway_id     = lookup(local.local_tgw_rtb_id_to_local_tgw_id, each.value.route_table_id)
}

locals {
  # build new local vpc routes to other local vpcs
  local_vpc_routes_to_other_local_tgws = [
    for rtb_id_and_local_tgw_networks in setproduct(local.local_tgws_all_vpc_routes[*].route_table_id, local.local_tgws_all_vpc_networks) : {
      destination_cidr_block = rtb_id_and_local_tgw_networks[1]
      route_table_id         = rtb_id_and_local_tgw_networks[0]
  }]

  # generate current existing local vpc routes
  local_current_vpc_routes = flatten(
    [for this in local.local_tgws :
      [for vpc_name, vpc in this.vpcs :
        [for rtb_id_and_vpc_network in setproduct(this.vpc_routes[*].route_table_id, [vpc.network]) : {
          destination_cidr_block = rtb_id_and_vpc_network[1]
          route_table_id         = rtb_id_and_vpc_network[0]
  }]]])

  # subtract current existing local vpc routes from all local vpc routes
  local_tgw_all_new_vpc_routes_to_other_local_vpcs = {
    for this in setsubtract(local.local_vpc_routes_to_other_local_tgws, local.local_current_vpc_routes) :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_local_vpcs_routes_to_other_local_vpcs" {
  provider = aws.local

  for_each = local.local_tgw_all_new_vpc_routes_to_other_local_vpcs

  destination_cidr_block = each.value.destination_cidr_block
  route_table_id         = each.value.route_table_id
  transit_gateway_id     = lookup(local.local_tgw_rtb_id_to_local_tgw_id, each.value.route_table_id)
}

locals {
  local_tgw_route_table_id_to_local_tgw_id = zipmap(local.local_tgws[*].route_table_id, local.local_tgws[*].id)

  # build new local tgw routes to other peer tgws
  local_tgw_routes_to_other_peer_tgws = [
    for rtb_id_and_peer_tgw_networks in setproduct(local.local_tgws[*].route_table_id, local.peer_tgws_all_vpc_networks) : {
      destination_cidr_block = rtb_id_and_peer_tgw_networks[1]
      route_table_id         = rtb_id_and_peer_tgw_networks[0]
  }]

  local_tgw_all_new_tgw_routes_to_vpc_in_other_tgws = {
    for this in local.local_tgw_routes_to_other_peer_tgws :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_ec2_transit_gateway_route" "this_local_tgw_routes_to_vpcs_in_other_tgws" {
  provider = aws.local

  for_each = local.local_tgw_all_new_tgw_routes_to_vpc_in_other_tgws

  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_route_table_id = each.value.route_table_id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals, lookup(local.local_tgw_route_table_id_to_local_tgw_id, each.value.route_table_id)).id

  # make sure the peer links are up before adding the route.????
  depends_on = [aws_ec2_transit_gateway_peering_attachment.this_local_to_locals]

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

locals {
  # build new local tgw routes to other local tgws
  local_tgws_routes_to_other_local_tgws = [
    for rtb_id_and_network in setproduct(local.local_tgws[*].route_table_id, local.local_tgws_all_vpc_networks) : {
      destination_cidr_block = rtb_id_and_network[1]
      route_table_id         = rtb_id_and_network[0]
    }
  ]

  # generate current existing local tgw routes for its local vpcs
  local_current_tgw_routes = flatten(
    [for this in local.local_tgws :
      [for vpc_name, vpc in this.vpcs :
        [for rtb_id_and_network in setproduct(this[*].route_table_id, [vpc.network]) : {
          destination_cidr_block = rtb_id_and_network[1]
          route_table_id         = rtb_id_and_network[0]
  }]]])

  # subtract current existing local tgw routes from all local tgw routes
  local_tgw_all_new_tgw_routes_to_other_local_tgws = {
    for this in setsubtract(local.local_tgws_routes_to_other_local_tgws, local.local_current_tgw_routes) :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_ec2_transit_gateway_route" "this_local_tgw_routes_to_other_local_tgws" {
  provider = aws.local

  for_each = local.local_tgw_all_new_tgw_routes_to_other_local_tgws

  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_route_table_id = each.value.route_table_id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals, lookup(local.local_tgw_route_table_id_to_local_tgw_id, each.value.route_table_id)).id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment.this_local_to_locals]
}

########################################################################################
# Begin Peer Side
########################################################################################

locals {
  peer_vpc_network_to_peer_tgw = merge(
    [for this in local.peer_tgws :
      { for vpc_name, vpc in this.vpcs :
        vpc.network => this
  }]...)
}

resource "aws_ec2_transit_gateway_route" "this_peer_vpc_to_peer_tgws" {
  provider = aws.local

  for_each = local.peer_vpc_network_to_peer_tgw

  destination_cidr_block         = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.this_local_to_peers, each.value.id).id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_locals]
}

resource "aws_ec2_transit_gateway_route_table_association" "this_peer" {
  provider = aws.local

  for_each = toset(local.peer_tgws[*].id)

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.this_local_to_peers, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id

  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_locals]
}

# associate peer tgw route table to attachment accepter
resource "aws_ec2_transit_gateway_route_table_association" "this_peer_to_locals" {
  provider = aws.peer

  for_each = local.peer_tgw_id_to_peer_tgw

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_locals, each.key).id
  transit_gateway_route_table_id = each.value.route_table_id

  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment.this_local_to_peers]
}

locals {
  # generate routes for peer vpcs in other local tgws
  # keep track of current rtb-id to tgw-id
  peer_tgw_rtb_id_to_peer_tgw_id = zipmap(local.peer_tgws_all_vpc_routes[*].route_table_id, local.peer_tgws_all_vpc_routes[*].transit_gateway_id)

  # build new vpc peer routes routes to other local tgws
  peer_vpc_routes_to_other_local_tgws = [
    for rtb_id_and_peer_tgw_networks in setproduct(local.peer_tgws_all_vpc_routes[*].route_table_id, local.local_tgws_all_vpc_networks) : {
      destination_cidr_block = rtb_id_and_peer_tgw_networks[1]
      route_table_id         = rtb_id_and_peer_tgw_networks[0]
  }]

  # add the tgw-id back in for each new route
  peer_tgw_all_new_vpc_routes_to_local_tgws = {
    for this in local.peer_vpc_routes_to_other_local_tgws :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_peer_vpc_routes_to_local_tgws" {
  provider = aws.peer

  for_each = local.peer_tgw_all_new_vpc_routes_to_local_tgws

  destination_cidr_block = each.value.destination_cidr_block
  route_table_id         = each.value.route_table_id
  transit_gateway_id     = lookup(local.peer_tgw_rtb_id_to_peer_tgw_id, each.value.route_table_id)
}

locals {
  # build new peer vpc routes to other peer vpcs
  peer_vpc_routes_to_other_peer_tgws = [
    for rtb_id_and_peer_tgw_networks in setproduct(local.peer_tgws_all_vpc_routes[*].route_table_id, local.peer_tgws_all_vpc_networks) : {
      destination_cidr_block = rtb_id_and_peer_tgw_networks[1]
      route_table_id         = rtb_id_and_peer_tgw_networks[0]
    }
  ]

  # generate current existing peer vpc routes
  peer_current_vpc_routes = flatten(
    [for this in local.peer_tgws :
      [for vpc_name, vpc in this.vpcs :
        [for rtb_id_and_network in setproduct(this.vpc_routes[*].route_table_id, [vpc.network]) : {
          destination_cidr_block = rtb_id_and_network[1]
          route_table_id         = rtb_id_and_network[0]
  }]]])

  # subtract current existing peer vpc routes from all peer vpc routes
  peer_tgw_all_new_vpc_routes_to_other_peer_vpcs = {
    for this in setsubtract(local.peer_vpc_routes_to_other_peer_tgws, local.peer_current_vpc_routes) :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_peer_vpcs_routes_to_other_peer_vpcs" {
  provider = aws.peer

  for_each = local.peer_tgw_all_new_vpc_routes_to_other_peer_vpcs

  destination_cidr_block = each.value.destination_cidr_block
  route_table_id         = each.value.route_table_id
  transit_gateway_id     = lookup(local.peer_tgw_rtb_id_to_peer_tgw_id, each.value.route_table_id)
}

locals {
  peer_tgw_route_table_id_to_peer_tgw_id = zipmap(local.peer_tgws[*].route_table_id, local.peer_tgws[*].id)

  # build new peer tgw routes to other local tgws
  peer_tgw_routes_to_other_tgws = [
    for rtb_id_and_peer_tgw_networks in setproduct(local.peer_tgws[*].route_table_id, local.local_tgws_all_vpc_networks) : {
      route_table_id         = rtb_id_and_peer_tgw_networks[0]
      destination_cidr_block = rtb_id_and_peer_tgw_networks[1]
  }]

  peer_tgw_all_new_tgw_routes_to_vpcs_in_other_tgws = {
    for this in local.peer_tgw_routes_to_other_tgws :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_ec2_transit_gateway_route" "this_peer_tgw_routes_to_vpcs_in_other_tgws" {
  provider = aws.peer

  for_each = local.peer_tgw_all_new_tgw_routes_to_vpcs_in_other_tgws

  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_route_table_id = each.value.route_table_id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_locals, lookup(local.peer_tgw_route_table_id_to_peer_tgw_id, each.value.route_table_id)).id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment.this_local_to_peers]
}

locals {
  # build new peer tgw routes to other peer tgws
  peer_tgws_routes_to_other_peer_tgws = [
    for rtb_id_and_network in setproduct(local.peer_tgws[*].route_table_id, local.peer_tgws_all_vpc_networks) : {
      destination_cidr_block = rtb_id_and_network[1]
      route_table_id         = rtb_id_and_network[0]
    }
  ]

  # generate current existing peer tgw routes for its peer vpcs
  peer_current_tgw_routes = flatten(
    [for this in local.peer_tgws :
      [for vpc_name, vpc in this.vpcs :
        [for rtb_id_and_network in setproduct(this[*].route_table_id, [vpc.network]) : {
          destination_cidr_block = rtb_id_and_network[1]
          route_table_id         = rtb_id_and_network[0]
  }]]])

  # subtract current existing peer tgw routes from all peer tgw routes
  peer_tgw_all_new_tgw_routes_to_other_peer_tgws = {
    for this in setsubtract(local.peer_tgws_routes_to_other_peer_tgws, local.peer_current_tgw_routes) :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_ec2_transit_gateway_route" "this_peer_tgw_routes_to_other_peer_tgws" {
  provider = aws.peer

  for_each = local.peer_tgw_all_new_tgw_routes_to_other_peer_tgws

  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_route_table_id = each.value.route_table_id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_locals, lookup(local.peer_tgw_route_table_id_to_peer_tgw_id, each.value.route_table_id)).id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment.this_local_to_peers]
}
