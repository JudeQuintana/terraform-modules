data "aws_caller_identity" "this_four" {
  provider = aws.four
}

data "aws_region" "this_four" {
  provider = aws.four
}

locals {
  four_provider_account_id  = data.aws_caller_identity.this_four.account_id
  four_provider_region_name = data.aws_region.this_four.name

  four_tgw                     = var.mega_mesh.four.centralized_router
  four_tgw_vpc_network_cidrs   = toset(local.four_tgw.vpc.network_cidrs)
  four_tgw_vpc_route_table_ids = toset(concat(local.four_tgw.vpc.private_route_table_ids, local.four_tgw.vpc.public_route_table_ids))
}

