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
  local_tgws_vpc_network_cidrs_and_route_table_ids_with_tgw_id = [
    for this in local.local_tgws : {
      vpc_network_cidrs      = flatten([for vpc in this.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)])
      vpc_ipv6_network_cidrs = flatten([for vpc in this.vpcs : concat(compact([vpc.ipv6_network_cidr]), vpc.ipv6_secondary_cidrs)])
      vpc_route_table_ids    = flatten([for vpc in this.vpcs : concat(vpc.private_route_table_ids, vpc.public_route_table_ids)])
      transit_gateway_id     = this.id
  }]

  local_vpc_network_cidr_to_local_tgw_id = merge([
    for this in local.local_tgws_vpc_network_cidrs_and_route_table_ids_with_tgw_id : {
      for vpc_network_cidr in this.vpc_network_cidrs :
      vpc_network_cidr => this.transit_gateway_id
  }]...)

  local_vpc_ipv6_network_cidr_to_local_tgw_id = merge([
    for this in local.local_tgws_vpc_network_cidrs_and_route_table_ids_with_tgw_id : {
      for vpc_ipv6_network_cidr in this.vpc_ipv6_network_cidrs :
      vpc_ipv6_network_cidr => this.transit_gateway_id
  }]...)

  # keep track of current rtb-id to tgw-id
  local_tgws_vpc_route_table_id_to_tgw_id = merge([
    for this in local.local_tgws_vpc_network_cidrs_and_route_table_ids_with_tgw_id : {
      for vpc_route_table_id in this.vpc_route_table_ids :
      vpc_route_table_id => this.transit_gateway_id
  }]...)

  local_tgws_vpc_tgw_id_to_route_table_ids = {
    for this in local.local_tgws_vpc_network_cidrs_and_route_table_ids_with_tgw_id :
    this.transit_gateway_id => this.vpc_route_table_ids
  }

  local_tgws_vpc_network_cidrs      = flatten(local.local_tgws_vpc_network_cidrs_and_route_table_ids_with_tgw_id[*].vpc_network_cidrs)
  local_tgws_vpc_ipv6_network_cidrs = flatten(local.local_tgws_vpc_network_cidrs_and_route_table_ids_with_tgw_id[*].vpc_ipv6_network_cidrs)
  local_tgws_vpc_route_table_ids    = flatten(local.local_tgws_vpc_network_cidrs_and_route_table_ids_with_tgw_id[*].vpc_route_table_ids)
  local_tgws_route_table_ids        = local.local_tgws[*].route_table_id
  local_tgws_ids                    = local.local_tgws[*].id
}

########################################################################################
# IPv4 Begin Local Centralized Router Side
#########################################################################################

# add all local tgw routes to local tgw super router
resource "aws_ec2_transit_gateway_route" "this_local" {
  provider = aws.local

  for_each = local.local_vpc_network_cidr_to_local_tgw_id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.this_local_to_locals, each.value).id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals]
}

locals {
  local_tgw_route_table_id_to_local_tgw_id = zipmap(local.local_tgws_route_table_ids, local.local_tgws_ids)

  # build new local tgw routes to other peer tgws
  local_tgw_routes_to_peer_tgws = [
    for pair in setproduct(local.local_tgws_route_table_ids, local.peer_tgws_vpc_network_cidrs) : {
      route_table_id         = pair[0]
      destination_cidr_block = pair[1]
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
}

locals {
  # build new local tgw routes to other local tgws
  local_tgws_routes_to_local_tgws = [
    for pair in setproduct(local.local_tgws_route_table_ids, local.local_tgws_vpc_network_cidrs) : {
      route_table_id         = pair[0]
      destination_cidr_block = pair[1]
  }]

  # generate current existing local tgw routes for its local vpcs
  local_current_tgw_routes = flatten([
    for this in local.local_tgws : [
      for pair in setproduct([this.route_table_id], flatten([for vpc in this.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)])) : {
        route_table_id         = pair[0]
        destination_cidr_block = pair[1]
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
# IPv4 Begin Local Super Router Side
#########################################################################################

# add all peer tgw routes to local tgw super router
resource "aws_ec2_transit_gateway_route" "this_local_to_peer_tgws" {
  provider = aws.local

  for_each = local.peer_vpc_network_cidr_to_peer_tgw_id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this_local_to_this_peer.id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_this_peer]
}

########################################################################################
# IPv6 Begin Local Centralized Router Side
#########################################################################################

# add all local tgw ipv6 routes to local tgw super router
resource "aws_ec2_transit_gateway_route" "this_local_ipv6" {
  provider = aws.local

  for_each = local.local_vpc_ipv6_network_cidr_to_local_tgw_id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.this_local_to_locals, each.value).id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals]
}

locals {
  # build new local tgw ipv6 routes to other peer tgws
  local_tgw_ipv6_routes_to_peer_tgws = [
    for pair in setproduct(local.local_tgws_route_table_ids, local.peer_tgws_vpc_ipv6_network_cidrs) : {
      route_table_id              = pair[0]
      destination_ipv6_cidr_block = pair[1]
  }]

  local_tgw_all_new_tgw_ipv6_routes_to_vpcs_in_peer_tgws = {
    for this in local.local_tgw_ipv6_routes_to_peer_tgws :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
  }
}

resource "aws_ec2_transit_gateway_route" "this_local_tgw_ipv6_routes_to_vpcs_in_peer_tgws" {
  provider = aws.local

  for_each = local.local_tgw_all_new_tgw_ipv6_routes_to_vpcs_in_peer_tgws

  transit_gateway_route_table_id = each.value.route_table_id
  destination_cidr_block         = each.value.destination_ipv6_cidr_block
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals, lookup(local.local_tgw_route_table_id_to_local_tgw_id, each.value.route_table_id)).id
}

locals {
  # build new local tgw ipv6 routes to other local tgws
  local_tgws_ipv6_routes_to_local_tgws = [
    for pair in setproduct(local.local_tgws_route_table_ids, local.local_tgws_vpc_ipv6_network_cidrs) : {
      route_table_id              = pair[0]
      destination_ipv6_cidr_block = pair[1]
  }]

  # generate current existing local tgw ipv6 routes for its local vpcs
  local_current_tgw_ipv6_routes = flatten([
    for this in local.local_tgws : [
      for pair in setproduct([this.route_table_id], flatten([for vpc in this.vpcs : concat(compact([vpc.ipv6_network_cidr]), vpc.ipv6_secondary_cidrs)])) : {
        route_table_id              = pair[0]
        destination_ipv6_cidr_block = pair[1]
  }]])

  # subtract current existing local tgw ipv6 routes from all local tgw ipv6 routes
  local_tgw_all_new_tgw_ipv6_routes_to_local_tgws = {
    for this in setsubtract(local.local_tgws_ipv6_routes_to_local_tgws, local.local_current_tgw_ipv6_routes) :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
  }
}

resource "aws_ec2_transit_gateway_route" "this_local_tgw_ipv6_routes_to_local_tgws" {
  provider = aws.local

  for_each = local.local_tgw_all_new_tgw_ipv6_routes_to_local_tgws

  transit_gateway_route_table_id = each.value.route_table_id
  destination_cidr_block         = each.value.destination_ipv6_cidr_block
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals, lookup(local.local_tgw_route_table_id_to_local_tgw_id, each.value.route_table_id)).id
}

########################################################################################
# IPv6 Begin Local Super Router Side
#########################################################################################

# add all peer tgw routes to local tgw super router
resource "aws_ec2_transit_gateway_route" "this_local_ipv6_to_peer_tgws" {
  provider = aws.local

  for_each = local.peer_vpc_ipv6_network_cidr_to_peer_tgw_id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this_local_to_this_peer.id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_this_peer]
}
