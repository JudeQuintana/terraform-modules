data "aws_caller_identity" "this_one" {
  provider = aws.one
}

data "aws_region" "this_one" {
  provider = aws.one
}

locals {
  one_provider_account_id  = data.aws_caller_identity.this_one.account_id
  one_provider_region_name = data.aws_region.this_one.name

  one_tgw                            = var.mega_mesh.one.centralized_router
  one_tgw_vpc_network_cidrs          = toset(local.one_tgw.vpc.network_cidrs)
  one_tgw_vpc_routes_route_table_ids = toset(local.one_tgw.vpc.routes[*].route_table_id)
}
