locals {
  private_ipv4_centralized_egress_route_any_cidr  = "0.0.0.0/0"
  private_ipv4_centralized_egress_route_table_ids = { for this in var.centralized_router.vpcs : this.private_route_table_ids => local.private_ipv4_centralized_egress_route_any_cidr if this.private_centralized_egress }
}

resource "aws_route" "this_private_centralized_egress_vpc_route_any" {
  for_each = local.private_ipv4_centralized_egress_route_table_id_to_route_any_cidr

  destination_cidr_block = each.value
  route_table_id         = each.key
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
}

locals {
  # validation: should only be one
  private_ipv4_centralized_egress_route_any_cidr_to_central_vpc_id = { for this in var.centralized_router.vpcs : local.private_ipv4_centralized_egress_route_any_cidr => this.id if this.central_centralized_egress }
}

resource "aws_ec2_transit_gateway_route" "this_central_centralized_egress_tgw_central_vpc_route_any" {
  for_each = local.private_ipv4_centralized_egress_route_any_cidr_to_central_vpc_id

  destination_cidr_block         = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.value).id
}

