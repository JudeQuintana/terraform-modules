locals {
  centralized_egress_route_any_cidr = "0.0.0.0/0"
  # will only be a map of 1 via validation if enabled
  centralized_egress_central_vpc_id_to_route_any_cidr = {
    for this in local.vpcs :
    this.id => local.centralized_egress_route_any_cidr
    if this.centralized_egress_central && !contains(var.centralized_router.blackhole.cidrs, local.centralized_egress_route_any_cidr)
  }
}

# central tgw route
resource "aws_ec2_transit_gateway_route" "this_centralized_egress_tgw_central_vpc_route_any" {
  for_each = local.centralized_egress_central_vpc_id_to_route_any_cidr

  destination_cidr_block         = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.key).id
}

