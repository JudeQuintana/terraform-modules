# Create routes to other VPC network_cidrs in private and public route tables for each VPC
module "this_generate_routes_to_other_vpcs" {
  source = "./modules/generate_routes_to_other_vpcs"

  vpcs = local.vpcs
}

locals {
  route_format = "%s|%s"
  vpc_routes_to_other_vpcs = {
    for this in module.this_generate_routes_to_other_vpcs.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this_vpc_routes_to_other_vpcs" {
  for_each = local.vpc_routes_to_other_vpcs

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.this.id

  # make sure the tgw route table is available first before the setting routes on the vpcs
  depends_on = [aws_ec2_transit_gateway_route_table.this]
}

# ipv6
locals {
  ipv6_vpc_routes_to_other_vpcs = {
    for this in module.this_generate_routes_to_other_vpcs.ipv6 :
    format(local.route_format, this.route_table_id, this.destination_ipv6_cidr_block) => this
  }
}

resource "aws_route" "this_ipv6_vpc_routes_to_other_vpcs" {
  for_each = local.ipv6_vpc_routes_to_other_vpcs

  route_table_id              = each.value.route_table_id
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  transit_gateway_id          = aws_ec2_transit_gateway.this.id

  # make sure the tgw route table is available first before the setting routes on the vpcs
  depends_on = [aws_ec2_transit_gateway_route_table.this]
}

