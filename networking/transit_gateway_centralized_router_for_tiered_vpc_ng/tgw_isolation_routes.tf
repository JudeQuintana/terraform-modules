locals {
  ipv4_subnet_cidr_to_vpc_id = merge([
    for this in var.centralized_router.vpcs : {
      for subnet_cidr in concat(this.public_subnet_cidrs, this.private_subnet_cidrs) :
      subnet_cidr => this.id
  }]...)

  isolated_ipv4_subnet_cidr_to_vpc_id = {
    for this in var.centralized_router.isolate.subnet_cidrs :
    this => lookup(local.ipv4_subnet_cidr_to_vpc_id, this)
  }
}

resource "aws_ec2_transit_gateway_route" "this_tgw_isolated_routes_to_vpcs" {
  for_each = local.isolated_ipv4_subnet_cidr_to_vpc_id

  destination_cidr_block         = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.value).id
}


locals {
  ipv6_subnet_cidr_to_vpc_id = merge([
    for this in var.centralized_router.vpcs : {
      for ipv6_subnet_cidr in concat(this.public_ipv6_subnet_cidrs, this.private_ipv6_subnet_cidrs) :
      ipv6_subnet_cidr => this.id
  }]...)

  isolated_ipv6_subnet_cidr_to_vpc_id = {
    for this in var.centralized_router.isolate.subnet_cidrs :
    this => lookup(local.ipv6_subnet_cidr_to_vpc_id, this)
  }
}

resource "aws_ec2_transit_gateway_route" "this_tgw_ipv6_isolated_routes_to_vpcs" {
  for_each = local.isolated_ipv6_subnet_cidr_to_vpc_id

  destination_cidr_block         = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.value).id
}
