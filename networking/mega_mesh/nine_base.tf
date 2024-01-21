data "aws_caller_identity" "this_nine" {
  provider = aws.nine
}

data "aws_region" "this_nine" {
  provider = aws.nine
}

locals {
  nine_provider_account_id  = data.aws_caller_identity.this_nine.account_id
  nine_provider_region_name = data.aws_region.this_nine.name

  nine_tgw                     = var.mega_mesh.nine.centralized_router
  nine_tgw_vpc_network_cidrs   = toset(local.nine_tgw.vpc.network_cidrs)
  nine_tgw_vpc_route_table_ids = toset(concat(local.nine_tgw.vpc.private_route_table_ids, local.nine_tgw.vpc.public_route_table_ids))
}

