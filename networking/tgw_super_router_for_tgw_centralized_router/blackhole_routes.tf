locals {
  blackhole_subnets = toset(var.super_router.blackhole_subnets)
}
resource "aws_ec2_transit_gateway_route" "this_local_blackhole" {
  for_each = local.super_router.blackhole_subnets

  destination_cidr_block         = each.value
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
}

resource "aws_ec2_transit_gateway_route" "this_peer_blackhole" {
  for_each = local.blackhole_subnets

  destination_cidr_block         = each.value
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_peer.id
}
