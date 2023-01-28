locals {
  blackhole_cidrs = toset(var.centralized_router.blackhole_cidrs)
}

resource "aws_ec2_transit_gateway_route" "this_blackholes" {
  for_each = local.blackhole_cidrs

  destination_cidr_block         = each.value
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}
