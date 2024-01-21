data "aws_caller_identity" "this_eight" {
  provider = aws.eight
}

data "aws_region" "this_eight" {
  provider = aws.eight
}

locals {
  eight_provider_account_id  = data.aws_caller_identity.this_eight.account_id
  eight_provider_region_name = data.aws_region.this_eight.name

  eight_tgw                     = var.mega_mesh.eight.centralized_router
  eight_tgw_vpc_network_cidrs   = toset(local.eight_tgw.vpc.network_cidrs)
  eight_tgw_vpc_route_table_ids = toset(concat(local.eight_tgw.vpc.private_route_table_ids, local.eight_tgw.vpc.public_route_table_ids))
}

