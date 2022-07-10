# one route table for all networks
resource "aws_ec2_transit_gateway_route_table" "local_this" {
  provider = aws.local

  transit_gateway_id = aws_ec2_transit_gateway.local_this.id
  tags = merge(
    local.default_tags,
    {
      Name = format("%s-%s-%s-%s", local.upper_env_prefix, "super-router", random_pet.this.id, local.local_region_label)
  })
}

locals {
  local_tgws = [for this in var.local_centralized_routers : merge(
    this, { peering_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment.local_peers, this.id).id }
  )]

  local_vpc_network_to_local_tgw = merge(
    [for this in local.local_tgws :
      { for vpc_name, vpc in this.vpcs :
        vpc.network => this
  }]...)
}

resource "aws_ec2_transit_gateway_route" "local_this" {
  provider = aws.local

  for_each = local.local_vpc_network_to_local_tgw

  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = each.value.peering_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.local_locals]

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "local_this" {
  provider = aws.local

  for_each = toset(local.local_tgws[*].id)

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.local_peers, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id
  #
  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.local_locals]

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

# associate local tgw route table to attachment accepter too
resource "aws_ec2_transit_gateway_route_table_association" "local_local" {
  provider = aws.local

  for_each = { for this in local.local_tgws : this.id => this }

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.local_locals, each.key).id
  transit_gateway_route_table_id = each.value.route_table_id

  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.local_locals]

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}
#
# You cannot propagate a tgw peering attachment to a Transit Gateway Route Table
# resource "aws_ec2_transit_gateway_route_table_propagation" "local_this" {}

locals {
  # generate routes for vpcs in other peer tgws
  local_tgws_all_vpc_routes  = flatten(local.local_tgws[*].routes)
  peer_tgws_all_vpc_networks = flatten(local.peer_tgws[*].networks)

  # keep track of current rtb-id to tgw-id
  local_tgw_rtb_id_to_local_tgw_id = zipmap(local.local_tgws_all_vpc_routes[*].rtb_id, local.local_tgws_all_vpc_routes[*].tgw_id)

  # build new vpc routes
  local_vpc_routes_to_other_peer_tgws = [
    for rtb_id_and_peer_tgw_networks in setproduct(local.local_tgws_all_vpc_routes[*].rtb_id, local.peer_tgws_all_vpc_networks) : {
      rtb_id = rtb_id_and_peer_tgw_networks[0]
      route  = rtb_id_and_peer_tgw_networks[1]
  }]

  # add the tgw-id back in for each new route
  local_tgw_all_new_vpc_routes = [
    for this in local.local_vpc_routes_to_other_peer_tgws :
    merge(this, { tgw_id = lookup(local.local_tgw_rtb_id_to_local_tgw_id, this.rtb_id) })
  ]
}

resource "aws_route" "local_vpc_routes" {
  provider = aws.local
  for_each = {
    for this in local.local_tgw_all_new_vpc_routes :
    format("%s|%s", this.rtb_id, this.route) => this
  }

  destination_cidr_block = each.value.route
  route_table_id         = each.value.rtb_id
  transit_gateway_id     = each.value.tgw_id

  #lifecycle {
  #ignore_changes = [transit_gateway_id]
  #} ??
}

locals {
  # build new vpc routes to other local vpcs
  local_vpc_routes_to_other_local_tgws = [
    for rtb_id_and_local_tgw_networks in setproduct(local.local_tgws_all_vpc_routes[*].rtb_id, local.local_tgws_all_vpc_networks) : {
      rtb_id = rtb_id_and_local_tgw_networks[0]
      route  = rtb_id_and_local_tgw_networks[1]
    }
    #if length(local.local_tgws) > 1 ??
  ]

  local_current_vpc_routes = flatten(
    [for this in local.local_tgws :
      [for vpc_name, vpc in this.vpcs :
        [for rtb_id_and_network in setproduct(this.routes[*].rtb_id, [vpc.network]) : {
          rtb_id = rtb_id_and_network[0]
          route  = rtb_id_and_network[1]
  }]]])

  # add the tgw-id back in for each new route
  local_tgw_all_new_vpc_routes_to_other_local_vpcs = [
    for this in setsubtract(local.local_vpc_routes_to_other_local_tgws, local.local_current_vpc_routes) :
    merge(this, { tgw_id = lookup(local.local_tgw_rtb_id_to_local_tgw_id, this.rtb_id) })
  ]

}

resource "aws_route" "local_vpcs_routes_to_other_local_vpcs" {
  provider = aws.local
  for_each = {
    for this in local.local_tgw_all_new_vpc_routes_to_other_local_vpcs :
    format("%s|%s", this.rtb_id, this.route) => this
  }

  destination_cidr_block = each.value.route
  route_table_id         = each.value.rtb_id
  transit_gateway_id     = each.value.tgw_id

  #lifecycle {
  #ignore_changes = [transit_gateway_id]
  #} ??
}

locals {
  local_tgw_route_table_id_to_tgw_id = zipmap(local.local_tgws[*].route_table_id, local.local_tgws[*].id)

  # build new tgw routes
  local_tgw_routes_to_other_tgws = [
    for rtb_id_and_peer_tgw_networks in setproduct(local.local_tgws[*].route_table_id, local.peer_tgws_all_vpc_networks) : {
      rtb_id = rtb_id_and_peer_tgw_networks[0]
      route  = rtb_id_and_peer_tgw_networks[1]
  }]

  # add the tgw-id back in for each new route
  local_tgw_all_new_tgw_routes = [
    for this in local.local_tgw_routes_to_other_tgws :
    merge(this, { transit_gateway_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.local_locals, lookup(local.local_tgw_route_table_id_to_tgw_id, this.rtb_id)).id })
  ]
}

resource "aws_ec2_transit_gateway_route" "this_local_tgw_routes_to_vpcs_in_other_tgws" {
  provider = aws.local

  for_each = {
    for this in local.local_tgw_all_new_tgw_routes :
    format("%s|%s", this.rtb_id, this.route) => this
  }

  destination_cidr_block         = each.value.route
  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = each.value.rtb_id

  # make sure the peer links are up before adding the route.????
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.local_locals]

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

locals {
  local_tgws_routes_to_other_local_tgws = [
    for rtb_id_and_network in setproduct(local.local_tgws[*].route_table_id, local.local_tgws_all_vpc_networks) : {
      rtb_id = rtb_id_and_network[0]
      route  = rtb_id_and_network[1]
    }
  ]

  local_current_tgw_routes = flatten(
    [for this in local.local_tgws :
      [for vpc_name, vpc in this.vpcs :
        [for rtb_id_and_network in setproduct(this[*].route_table_id, [vpc.network]) : {
          rtb_id = rtb_id_and_network[0]
          route  = rtb_id_and_network[1]
  }]]])

  # add the tgw-attachment-id back in for each new tgw route
  local_tgw_all_new_tgw_routes_to_other_local_tgws = [
    for this in setsubtract(local.local_tgws_routes_to_other_local_tgws, local.local_current_tgw_routes) :
    merge(this, { transit_gateway_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.local_locals, lookup(local.local_tgw_route_table_id_to_tgw_id, this.rtb_id)).id })
  ]
}

resource "aws_ec2_transit_gateway_route" "this_local_tgw_routes_to_other_local_tgws" {
  provider = aws.local

  for_each = {
    for this in local.local_tgw_all_new_tgw_routes_to_other_local_tgws :
    format("%s|%s", this.rtb_id, this.route) => this
  }

  destination_cidr_block         = each.value.route
  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = each.value.rtb_id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.local_locals]

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

########################################################################################
# Begin Peer
########################################################################################

locals {
  peer_tgws = [for this in var.peer_centralized_routers :
    merge(this, { peering_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment.peer_peers, this.id).id }
  )]

  peer_vpc_network_to_peer_tgw = merge(
    [for this in local.peer_tgws :
      { for vpc_name, vpc in this.vpcs :
        vpc.network => this
  }]...)
}

resource "aws_ec2_transit_gateway_route" "peer_this" {
  provider = aws.local

  for_each = local.peer_vpc_network_to_peer_tgw

  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = each.value.peering_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.peer_locals]

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "peer_this" {
  provider = aws.local

  for_each = toset(local.peer_tgws[*].id)

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.peer_peers, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id

  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.peer_locals]

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

# associate peer tgw route table to attachment accepter
resource "aws_ec2_transit_gateway_route_table_association" "peer_local" {
  provider = aws.peer

  for_each = { for this in local.peer_tgws : this.id => this }

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.peer_locals, each.key).id
  transit_gateway_route_table_id = each.value.route_table_id

  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.peer_locals]

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

locals {
  # generate routes for vpcs in other local tgws
  peer_tgws_all_vpc_routes    = flatten(local.peer_tgws[*].routes)
  local_tgws_all_vpc_networks = flatten(local.local_tgws[*].networks)

  # keep track of current rtb-id to tgw-id
  peer_tgw_rtb_id_to_peer_tgw_id = zipmap(local.peer_tgws_all_vpc_routes[*].rtb_id, local.peer_tgws_all_vpc_routes[*].tgw_id)

  # build new routes
  peer_vpc_routes_to_other_tgws = [
    for rtb_id_and_peer_tgw_networks in setproduct(local.peer_tgws_all_vpc_routes[*].rtb_id, local.local_tgws_all_vpc_networks) : {
      rtb_id = rtb_id_and_peer_tgw_networks[0]
      route  = rtb_id_and_peer_tgw_networks[1]
  }]

  # add the tgw-id back in for each new route
  peer_tgw_all_new_vpc_routes = [
    for this in local.peer_vpc_routes_to_other_tgws :
    merge(this, { tgw_id = lookup(local.peer_tgw_rtb_id_to_peer_tgw_id, this.rtb_id) })
  ]
}

resource "aws_route" "peer_vpc_routes" {
  provider = aws.peer
  for_each = {
    for this in local.peer_tgw_all_new_vpc_routes :
    format("%s|%s", this.rtb_id, this.route) => this
  }

  destination_cidr_block = each.value.route
  route_table_id         = each.value.rtb_id
  transit_gateway_id     = each.value.tgw_id

  #lifecycle {
  #ignore_changes = [transit_gateway_id]
  #} ??
}

locals {
  # build new vpc routes to other local vpcs
  peer_vpc_routes_to_other_peer_tgws = [
    for rtb_id_and_peer_tgw_networks in setproduct(local.peer_tgws_all_vpc_routes[*].rtb_id, local.peer_tgws_all_vpc_networks) : {
      rtb_id = rtb_id_and_peer_tgw_networks[0]
      route  = rtb_id_and_peer_tgw_networks[1]
    }
    #if length(local.local_tgws) > 1 ??
  ]

  peer_current_vpc_routes = flatten(
    [for this in local.peer_tgws :
      [for vpc_name, vpc in this.vpcs :
        [for rtb_id_and_network in setproduct(this.routes[*].rtb_id, [vpc.network]) : {
          rtb_id = rtb_id_and_network[0]
          route  = rtb_id_and_network[1]
  }]]])

  # add the tgw-id back in for each new route
  peer_tgw_all_new_vpc_routes_to_other_peer_vpcs = [
    for this in setsubtract(local.peer_vpc_routes_to_other_peer_tgws, local.peer_current_vpc_routes) :
    merge(this, { tgw_id = lookup(local.peer_tgw_rtb_id_to_peer_tgw_id, this.rtb_id) })
  ]

}

resource "aws_route" "peer_vpcs_routes_to_other_peer_vpcs" {
  provider = aws.peer
  for_each = {
    for this in local.peer_tgw_all_new_vpc_routes_to_other_peer_vpcs :
    format("%s|%s", this.rtb_id, this.route) => this
  }

  destination_cidr_block = each.value.route
  route_table_id         = each.value.rtb_id
  transit_gateway_id     = each.value.tgw_id

  #lifecycle {
  #ignore_changes = [transit_gateway_id]
  #} ??
}

locals {
  peer_tgw_route_table_id_to_tgw_id = zipmap(local.peer_tgws[*].route_table_id, local.peer_tgws[*].id)

  # build new tgw routes
  peer_tgw_routes_to_other_tgws = [
    for rtb_id_and_peer_tgw_networks in setproduct(local.peer_tgws[*].route_table_id, local.local_tgws_all_vpc_networks) : {
      rtb_id = rtb_id_and_peer_tgw_networks[0]
      route  = rtb_id_and_peer_tgw_networks[1]
  }]

  # add the tgw-id back in for each new route
  peer_tgw_all_new_tgw_routes = [
    for this in local.peer_tgw_routes_to_other_tgws :
    merge(this, { transit_gateway_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.peer_locals, lookup(local.peer_tgw_route_table_id_to_tgw_id, this.rtb_id)).id })
  ]
}

resource "aws_ec2_transit_gateway_route" "this_peer_tgw_routes_to_vpcs_in_other_tgws" {
  provider = aws.peer

  for_each = {
    for this in local.peer_tgw_all_new_tgw_routes :
    format("%s|%s", this.rtb_id, this.route) => this
  }

  destination_cidr_block         = each.value.route
  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = each.value.rtb_id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.peer_locals]

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

locals {
  peer_tgws_routes_to_other_peer_tgws = [
    for rtb_id_and_network in setproduct(local.peer_tgws[*].route_table_id, local.peer_tgws_all_vpc_networks) : {
      rtb_id = rtb_id_and_network[0]
      route  = rtb_id_and_network[1]
    }
  ]

  peer_current_tgw_routes = flatten(
    [for this in local.peer_tgws :
      [for vpc_name, vpc in this.vpcs :
        [for rtb_id_and_network in setproduct(this[*].route_table_id, [vpc.network]) : {
          rtb_id = rtb_id_and_network[0]
          route  = rtb_id_and_network[1]
  }]]])

  # add the tgw-attachment-id back in for each new tgw route
  peer_tgw_all_new_tgw_routes_to_other_peer_tgws = [
    for this in setsubtract(local.peer_tgws_routes_to_other_peer_tgws, local.peer_current_tgw_routes) :
    merge(this, { transit_gateway_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.peer_locals, lookup(local.peer_tgw_route_table_id_to_tgw_id, this.rtb_id)).id })
  ]
}

resource "aws_ec2_transit_gateway_route" "this_peer_tgw_routes_to_other_peer_tgws" {
  provider = aws.peer

  for_each = {
    for this in local.peer_tgw_all_new_tgw_routes_to_other_peer_tgws :
    format("%s|%s", this.rtb_id, this.route) => this
  }

  destination_cidr_block         = each.value.route
  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = each.value.rtb_id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.peer_locals]

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}
