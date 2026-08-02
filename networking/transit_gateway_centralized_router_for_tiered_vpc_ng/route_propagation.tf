# propagate routes for all attachments
locals {
  propagate_routes_vpc_id_to_vpc_attachment = { for this in local.vpc_id_to_vpc_attachment : this.id => this if var.centralized_router.propagate_routes }
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = local.propagate_routes_vpc_id_to_vpc_attachment

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}

