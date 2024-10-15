data "aws_caller_identity" "this_two" {
  provider = aws.two
}

data "aws_region" "this_two" {
  provider = aws.two
}

locals {
  two_provider_account_id  = data.aws_caller_identity.this_two.account_id
  two_provider_region_name = data.aws_region.this_two.name

  two_tgw                        = var.full_mesh_trio.two.centralized_router
  two_tgw_vpc_network_cidrs      = toset(concat(local.two_tgw.vpc.network_cidrs, local.two_tgw.vpc.secondary_cidrs))
  two_tgw_vpc_ipv6_network_cidrs = toset(concat(local.two_tgw.vpc.ipv6_network_cidrs, local.two_tgw.vpc.ipv6_secondary_cidrs))
  two_tgw_vpc_route_table_ids    = toset(concat(local.two_tgw.vpc.private_route_table_ids, local.two_tgw.vpc.public_route_table_ids))
}
