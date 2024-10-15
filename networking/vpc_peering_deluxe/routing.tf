locals {
  route_format = "%s|%s"

  only_route_subnet_cidrs      = length(var.vpc_peering_deluxe.local.only_route.subnet_cidrs) > 0 && length(var.vpc_peering_deluxe.peer.only_route.subnet_cidrs) > 0
  only_route_ipv6_subnet_cidrs = length(var.vpc_peering_deluxe.local.only_route.ipv6_subnet_cidrs) > 0 && length(var.vpc_peering_deluxe.peer.only_route.ipv6_subnet_cidrs) > 0

  local_vpc_route_table_ids   = toset(concat(var.vpc_peering_deluxe.local.vpc.private_route_table_ids, var.vpc_peering_deluxe.local.vpc.public_route_table_ids))
  local_vpc_subnet_cidrs      = local.only_route_subnet_cidrs ? toset(var.vpc_peering_deluxe.local.only_route.subnet_cidrs) : toset(concat(var.vpc_peering_deluxe.local.vpc.private_subnet_cidrs, var.vpc_peering_deluxe.local.vpc.public_subnet_cidrs))
  local_vpc_ipv6_subnet_cidrs = local.only_route_ipv6_subnet_cidrs ? toset(var.vpc_peering_deluxe.local.only_route.ipv6_subnet_cidrs) : toset(concat(var.vpc_peering_deluxe.local.vpc.private_ipv6_subnet_cidrs, var.vpc_peering_deluxe.local.vpc.public_ipv6_subnet_cidrs)) # dont need compact()

  peer_route_table_ids       = toset(concat(var.vpc_peering_deluxe.peer.vpc.private_route_table_ids, var.vpc_peering_deluxe.peer.vpc.public_route_table_ids))
  peer_vpc_subnet_cidrs      = local.only_route_subnet_cidrs ? toset(var.vpc_peering_deluxe.peer.only_route.subnet_cidrs) : toset(concat(var.vpc_peering_deluxe.peer.vpc.private_subnet_cidrs, var.vpc_peering_deluxe.peer.vpc.public_subnet_cidrs))
  peer_vpc_ipv6_subnet_cidrs = local.only_route_ipv6_subnet_cidrs ? toset(var.vpc_peering_deluxe.peer.only_route.ipv6_subnet_cidrs) : toset(concat(var.vpc_peering_deluxe.peer.vpc.private_ipv6_subnet_cidrs, var.vpc_peering_deluxe.peer.vpc.public_ipv6_subnet_cidrs)) # dont need compact()

  local_vpc_routes_to_peer_vpc_subnet_cidrs = [
    for local_vpc_route_table_id_and_peer_vpc_subnet_cidr in setproduct(local.local_vpc_route_table_ids, local.peer_vpc_subnet_cidrs) : {
      route_table_id         = local_vpc_route_table_id_and_peer_vpc_subnet_cidr[0]
      destination_cidr_block = local_vpc_route_table_id_and_peer_vpc_subnet_cidr[1]
  }]

  local_new_vpc_routes_to_peer_vpc_subnet_cidrs = {
    for this in local.local_vpc_routes_to_peer_vpc_subnet_cidrs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }

  local_vpc_ipv6_routes_to_peer_vpc_ipv6_subnet_cidrs = [
    for local_vpc_route_table_id_and_peer_vpc_ipv6_subnet_cidr in setproduct(local.local_vpc_route_table_ids, local.peer_vpc_ipv6_subnet_cidrs) : {
      route_table_id              = local_vpc_route_table_id_and_peer_vpc_ipv6_subnet_cidr[0]
      destination_ipv6_cidr_block = local_vpc_route_table_id_and_peer_vpc_ipv6_subnet_cidr[1]
  }]

  local_new_vpc_ipv6_routes_to_peer_vpc_ipv6_subnet_cidrs = {
    for this in local.local_vpc_ipv6_routes_to_peer_vpc_ipv6_subnet_cidrs :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
  }

  peer_vpc_routes_to_local_vpc_subnet_cidrs = [
    for peer_vpc_route_table_id_and_local_vpc_subnet_cidr in setproduct(local.peer_route_table_ids, local.local_vpc_subnet_cidrs) : {
      route_table_id         = peer_vpc_route_table_id_and_local_vpc_subnet_cidr[0]
      destination_cidr_block = peer_vpc_route_table_id_and_local_vpc_subnet_cidr[1]
  }]

  peer_new_vpc_routes_to_local_vpc_subnet_cidrs = {
    for this in local.peer_vpc_routes_to_local_vpc_subnet_cidrs :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }

  peer_vpc_ipv6_routes_to_local_vpc_ipv6_subnet_cidrs = [
    for peer_vpc_route_table_id_and_local_vpc_ipv6_subnet_cidr in setproduct(local.peer_route_table_ids, local.local_vpc_ipv6_subnet_cidrs) : {
      route_table_id              = peer_vpc_route_table_id_and_local_vpc_ipv6_subnet_cidr[0]
      destination_ipv6_cidr_block = peer_vpc_route_table_id_and_local_vpc_ipv6_subnet_cidr[1]
  }]

  peer_new_vpc_ipv6_routes_to_local_vpc_ipv6_subnet_cidrs = {
    for this in local.peer_vpc_ipv6_routes_to_local_vpc_ipv6_subnet_cidrs :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
  }
}

# Add VPC peering route to local and peer routing tables
# #ipv4
resource "aws_route" "this_local_to_this_peer" {
  provider = aws.local

  for_each = local.local_new_vpc_routes_to_peer_vpc_subnet_cidrs

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.this_local_to_this_peer.id
  route_table_id            = each.value.route_table_id
  destination_cidr_block    = each.value.destination_cidr_block
}

resource "aws_route" "this_peer_to_this_local" {
  provider = aws.peer

  for_each = local.peer_new_vpc_routes_to_local_vpc_subnet_cidrs

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.this_local_to_this_peer.id
  route_table_id            = each.value.route_table_id
  destination_cidr_block    = each.value.destination_cidr_block
}

#ipv6
resource "aws_route" "this_ipv6_local_to_this_peer" {
  provider = aws.local

  for_each = local.local_new_vpc_ipv6_routes_to_peer_vpc_ipv6_subnet_cidrs

  vpc_peering_connection_id   = aws_vpc_peering_connection_accepter.this_local_to_this_peer.id
  route_table_id              = each.value.route_table_id
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
}

resource "aws_route" "this_ipv6_peer_to_this_local" {
  provider = aws.peer

  for_each = local.peer_new_vpc_ipv6_routes_to_local_vpc_ipv6_subnet_cidrs

  vpc_peering_connection_id   = aws_vpc_peering_connection_accepter.this_local_to_this_peer.id
  route_table_id              = each.value.route_table_id
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
}

