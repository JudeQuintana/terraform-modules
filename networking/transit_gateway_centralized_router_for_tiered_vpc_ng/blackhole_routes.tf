resource "aws_ec2_transit_gateway_route" "blackhole" {
  for_each = toset(var.centralized_router.blackhole_subnets)

  destination_cidr_block         = each.value
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}
