# Create routes to other VPC network_cidrs in private and public route tables for each VPC
module "generate_routes_to_other_vpcs" {
  #source = "git@github.com:JudeQuintana/terraform-modules.git//utils/generate_routes_to_other_vpcs?ref=v1.4.1"
  source = "git@github.com:JudeQuintana/terraform-modules.git//utils/generate_routes_to_other_vpcs?ref=moar-better"

  vpcs = var.centralized_router.vpcs
}

locals {
  vpc_routes_to_other_vpcs = {
    for this in module.generate_routes_to_other_vpcs.call :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

resource "aws_route" "this" {
  for_each = local.vpc_routes_to_other_vpcs

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.this.id

  lifecyle {
    # make sure the route table exists first
    depends_on = [aws_ec2_transit_gateway_route_table.this]
  }
}
