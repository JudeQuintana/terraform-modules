locals {
  centralized_egress_route_any_cidr = "0.0.0.0/0"
  # validation: should only be one
  centralized_egress_route_any_cidr_to_central_vpc_id = {
    for this in var.centralized_router.vpcs :
    local.centralized_egress_route_any_cidr => this.id
    if this.centralized_egress_central
  }
}

resource "aws_ec2_transit_gateway_route" "this_central_centralized_egress_tgw_central_vpc_route_any" {
  for_each = local.centralized_egress_route_any_cidr_to_central_vpc_id

  destination_cidr_block         = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.value).id
}

locals {
  centralized_egress_private_route_table_id_to_route_any_cidr = merge([
    for this in var.centralized_router.vpcs : {
      for private_route_table_id in this.private_route_table_ids :
      private_route_table_id => local.centralized_egress_route_any_cidr
      if this.centralized_egress_private
  }]...)
}

resource "aws_route" "this_centralized_egress_private_vpc_route_any" {
  for_each = local.centralized_egress_private_route_table_id_to_route_any_cidr

  destination_cidr_block = each.value
  route_table_id         = each.key
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
}

locals {
  centralized_egress_public_route_table_id_to_route_any_cidr = merge([
    for this in var.centralized_router.vpcs : {
      for public_route_table_id in this.public_route_table_ids :
      public_route_table_id => local.centralized_egress_route_any_cidr
      if this.centralized_egress_public
  }]...)
}

resource "aws_route" "this_centralized_egress_public_vpc_route_any" {
  for_each = local.centralized_egress_public_route_table_id_to_route_any_cidr

  destination_cidr_block = each.value
  route_table_id         = each.key
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
}

