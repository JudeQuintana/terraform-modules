locals {
  peer_blackhole_cidrs = toset(concat(var.super_router.peer.blackhole.cidrs, var.super_router.peer.blackhole.ipv6_cidrs))
}

# destination_cidr_block can be ipv4 or ipv6 (no separate attribute or resource)
resource "aws_ec2_transit_gateway_route" "this_peer_blackholes" {
  provider = aws.peer

  for_each = local.peer_blackhole_cidrs

  destination_cidr_block         = each.value
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_peer.id
}

