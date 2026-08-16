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
  one_tgw_vpc_network_cidrs      = toset(flatten([for vpc in local.one_tgw.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)]))
  one_tgw_vpc_ipv6_network_cidrs = toset(flatten([for vpc in local.one_tgw.vpcs : concat(compact([vpc.ipv6_network_cidr]), vpc.ipv6_secondary_cidrs)]))
  one_tgw_vpc_route_table_ids    = toset(flatten([for vpc in local.one_tgw.vpcs : concat(vpc.private_route_table_ids, vpc.public_route_table_ids)]))
}
