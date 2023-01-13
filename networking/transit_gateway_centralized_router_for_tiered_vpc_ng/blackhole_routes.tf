resource "aws_ec2_transit_gateway_route" "this_blackhole" {
  for_each = toset(var.centralized_router.blackhole_subnet_cidrs)

  destination_cidr_block         = each.value
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}
