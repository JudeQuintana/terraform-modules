data "aws_caller_identity" "this_three" {
  provider = aws.three
}

data "aws_region" "this_three" {
  provider = aws.three
}

locals {
  three_provider_account_id  = data.aws_caller_identity.this_three.account_id
  three_provider_region_name = data.aws_region.this_three.name

  three_tgw                        = var.full_mesh_trio.three.centralized_router
  three_tgw_vpc_network_cidrs      = toset(flatten([for vpc in local.three_tgw.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)]))
  three_tgw_vpc_ipv6_network_cidrs = toset(flatten([for vpc in local.three_tgw.vpcs : concat(compact([vpc.ipv6_network_cidr]), vpc.ipv6_secondary_cidrs)]))
  three_tgw_vpc_route_table_ids    = toset(flatten([for vpc in local.three_tgw.vpcs : concat(vpc.private_route_table_ids, vpc.public_route_table_ids)]))
}
