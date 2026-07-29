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
  two_tgw_vpc_network_cidrs      = toset(flatten([for vpc in local.two_tgw.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)]))
  two_tgw_vpc_ipv6_network_cidrs = toset(flatten([for vpc in local.two_tgw.vpcs : concat(compact([vpc.ipv6_network_cidr]), vpc.ipv6_secondary_cidrs)]))
  two_tgw_vpc_route_table_ids    = toset(flatten([for vpc in local.two_tgw.vpcs : concat(vpc.private_route_table_ids, vpc.public_route_table_ids)]))
}
