locals {
  all_ipv4_subnet_cidr_to_vpc_id = merge([
    for this in var.centralized_router.vpcs : {
      for subnet_cidr in concat(this.public_subnet_cidrs, this.private_subnet_cidrs) :
      subnet_cidr => this.id
  }]...)

  ipv4_subnet_cidr_to_vpc_id = {
    for this in var.centralized_router.route_vpc_subnet.cidrs :
    this => lookup(local.all_ipv4_subnet_cidr_to_vpc_id, this)
  }
}

resource "aws_ec2_transit_gateway_route" "this_tgw_subnet_routes_to_vpcs" {
  for_each = local.ipv4_subnet_cidr_to_vpc_id

  destination_cidr_block         = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.value).id
}


locals {
  all_ipv6_subnet_cidr_to_vpc_id = merge([
    for this in var.centralized_router.vpcs : {
      for ipv6_subnet_cidr in concat(this.public_ipv6_subnet_cidrs, this.private_ipv6_subnet_cidrs) :
      ipv6_subnet_cidr => this.id
  }]...)

  ipv6_subnet_cidr_to_vpc_id = {
    for this in var.centralized_router.route_vpc_subnet.ipv6_cidrs :
    this => lookup(local.all_ipv6_subnet_cidr_to_vpc_id, this)
  }
}

resource "aws_ec2_transit_gateway_route" "this_tgw_ipv6_subnet_routes_to_vpcs" {
  for_each = local.ipv6_subnet_cidr_to_vpc_id

  destination_cidr_block         = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.value).id
}
