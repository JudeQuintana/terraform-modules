locals {
  blackhole_cidrs = toset(var.super_router.blackhole_cidrs)
}

resource "aws_ec2_transit_gateway_route" "this_local_blackholes" {
  provider = aws.local

  for_each = local.blackhole_cidrs

  destination_cidr_block         = each.value
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
}

resource "aws_ec2_transit_gateway_route" "this_peer_blackholes" {
  provider = aws.peer

  for_each = local.blackhole_cidrs

  destination_cidr_block         = each.value
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_peer.id
}
