# Create routes to other VPC network_cidrs in private and public route tables for each VPC
module "this_generate_routes_to_other_vpcs" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/transit_gateway_centralized_router_for_tiered_vpc_ng/modules/generate_routes_to_other_vpcs?ref=init-deny-policy"

  vpcs   = local.vpcs
  policy = var.policy
}

locals {
  route_format = "%s|%s"
  vpc_routes_to_other_vpcs = {
    for this in module.this_generate_routes_to_other_vpcs.ipv4 :
    format(local.route_format, this.route_table_id, this.destination_cidr_block) => this
  }
}

