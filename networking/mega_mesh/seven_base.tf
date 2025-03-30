data "aws_caller_identity" "this_seven" {
  provider = aws.seven
}

data "aws_region" "this_seven" {
  provider = aws.seven
}

locals {
  seven_provider_account_id  = data.aws_caller_identity.this_seven.account_id
  seven_provider_region_name = data.aws_region.this_seven.name

  seven_tgw                        = var.mega_mesh.seven.centralized_router
  seven_tgw_vpc_network_cidrs      = toset(concat(local.seven_tgw.vpc.network_cidrs, local.seven_tgw.vpc.secondary_cidrs))
  seven_tgw_vpc_ipv6_network_cidrs = toset(cocnat(local.seven_tgw.vpc.ipv6_network_cidrs, local.seven_tgw.vpc.ipv6_secondary_cidrs))
  seven_tgw_vpc_route_table_ids    = toset(concat(local.seven_tgw.vpc.private_route_table_ids, local.seven_tgw.vpc.public_route_table_ids))
}

