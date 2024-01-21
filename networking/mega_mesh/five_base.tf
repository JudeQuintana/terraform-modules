data "aws_caller_identity" "this_five" {
  provider = aws.five
}

data "aws_region" "this_five" {
  provider = aws.five
}

locals {
  five_provider_account_id  = data.aws_caller_identity.this_five.account_id
  five_provider_region_name = data.aws_region.this_five.name

  five_tgw                     = var.mega_mesh.five.centralized_router
  five_tgw_vpc_network_cidrs   = toset(local.five_tgw.vpc.network_cidrs)
  five_tgw_vpc_route_table_ids = toset(concat(local.five_tgw.vpc.private_route_table_ids, local.five_tgw.vpc.public_route_table_ids))
}
