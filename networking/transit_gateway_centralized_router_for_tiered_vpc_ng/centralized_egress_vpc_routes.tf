locals {
  centralized_egress_private_route_table_id_to_route_any_cidr = merge([
    for this in local.vpcs : {
      for private_route_table_id in this.private_route_table_ids :
      private_route_table_id => local.centralized_egress_route_any_cidr
    } if this.centralized_egress_private
  ]...)
}

# private vpc routes
resource "aws_route" "this_centralized_egress_private_vpc_route_any" {
  for_each = local.centralized_egress_private_route_table_id_to_route_any_cidr

  destination_cidr_block = each.value
  route_table_id         = each.key
  transit_gateway_id     = aws_ec2_transit_gateway.this.id

  # make sure the tgw route table is available first before the setting routes on the vpcs
  depends_on = [aws_ec2_transit_gateway_route_table.this]
}

