data "aws_caller_identity" "this_one" {
  provider = aws.one
}

data "aws_region" "this_one" {
  provider = aws.one
}

locals {
  one_provider_account_id  = data.aws_caller_identity.this_one.account_id
  one_provider_region_name = data.aws_region.this_one.name

  one_tgw                        = var.full_mesh_trio.one.centralized_router
  one_tgw_vpc_network_cidrs      = toset(concat(local.one_tgw.vpc.network_cidrs, local.one_tgw.vpc.secondary_cidrs))
  one_tgw_vpc_ipv6_network_cidrs = toset(concat(local.one_tgw.vpc.ipv6_network_cidrs, local.one_tgw.vpc.ipv6_secondary_cidrs))
  one_tgw_vpc_route_table_ids    = toset(concat(local.one_tgw.vpc.private_route_table_ids, local.one_tgw.vpc.public_route_table_ids))
}
