data "aws_caller_identity" "this_three" {
  provider = aws.three
}

data "aws_region" "this_three" {
  provider = aws.three
}

locals {
  three_provider_account_id  = data.aws_caller_identity.this_three.account_id
  three_provider_region_name = data.aws_region.this_three.name

  three_tgw                            = var.mega_mesh.three.centralized_router
  three_tgw_vpc_network_cidrs          = local.three_tgw.vpc.network_cidrs
  three_tgw_vpc_routes_route_table_ids = local.three_tgw.vpc.routes[*].route_table_id
}

