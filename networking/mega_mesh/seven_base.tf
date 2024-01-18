data "aws_caller_identity" "this_seven" {
  provider = aws.seven
}

data "aws_region" "this_seven" {
  provider = aws.seven
}

locals {
  seven_provider_account_id  = data.aws_caller_identity.this_seven.account_id
  seven_provider_region_name = data.aws_region.this_seven.name

  seven_tgw                            = var.mega_mesh.seven.centralized_router
  seven_tgw_vpc_network_cidrs          = toset(local.seven_tgw.vpc.network_cidrs)
  seven_tgw_vpc_routes_route_table_ids = toset(local.seven_tgw.vpc.routes[*].route_table_id)
}

