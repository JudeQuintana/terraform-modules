data "aws_caller_identity" "this_ten" {
  provider = aws.ten
}

data "aws_region" "this_ten" {
  provider = aws.ten
}

locals {
  ten_provider_account_id  = data.aws_caller_identity.this_ten.account_id
  ten_provider_region_name = data.aws_region.this_ten.name

  ten_tgw                     = var.mega_mesh.ten.centralized_router
  ten_tgw_vpc_network_cidrs   = toset(local.ten_tgw.vpc.network_cidrs)
  ten_tgw_vpc_route_table_ids = toset(concat(local.ten_tgw.vpc.private_route_table_ids, local.ten_tgw.vpc.public_route_table_ids))
}

