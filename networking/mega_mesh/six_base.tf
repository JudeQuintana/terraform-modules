data "aws_caller_identity" "this_six" {
  provider = aws.six
}

data "aws_region" "this_six" {
  provider = aws.six
}

locals {
  six_provider_account_id  = data.aws_caller_identity.this_six.account_id
  six_provider_region_name = data.aws_region.this_six.name

  six_tgw                     = var.mega_mesh.six.centralized_router
  six_tgw_vpc_network_cidrs   = toset(local.six_tgw.vpc.network_cidrs)
  six_tgw_vpc_route_table_ids = toset(concat(local.six_tgw.vpc.private_route_table_ids, local.six_tgw.vpc.public_route_table_ids))
}

