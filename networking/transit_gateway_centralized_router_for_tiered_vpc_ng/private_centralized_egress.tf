locals {
  route_any_cidr                             = "0.0.0.0/0"
  private_centralized_egress_route_table_ids = toset(flatten([for this in var.centralized_router.vpcs : this.private_route_table_ids if this.centralized_egress.private.opt_in]))
}

resource "aws_route" "this_private_centralized_egress_vpc_route_out" {
  for_each = local.private_centralized_egress_route_table_ids

  destination_cidr_block = local.route_any_cidr
  route_table_id         = each.key
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
}

locals {
  # validation: should only be one
  private_centralized_egress_route_any_cidr_to_central_vpc_id = { for this in var.centralized_router.vpcs : local.route_any_cidr => this.id if this.centralized_egress.private.central }
}

resource "aws_ec2_transit_gateway_route" "this_centralized_egress_tgw_central_vpc_routes" {
  for_each = local.private_centralized_egress_route_any_cidr_to_central_vpc_id

  destination_cidr_block         = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.value).id
}

