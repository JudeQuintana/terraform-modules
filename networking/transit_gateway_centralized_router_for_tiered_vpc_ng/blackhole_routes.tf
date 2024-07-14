locals {
  blackhole_all_cidrs = toset(concat(var.centralized_router.blackhole.cidrs, var.centralized_router.blackhole.ipv6_cidrs))
}

resource "aws_ec2_transit_gateway_route" "this_blackholes" {
  for_each = local.blackhole_all_cidrs

  # destination_cidr_block can be ipv4 or ipv6 (no separate attribute or resource)
  destination_cidr_block         = each.value
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}
