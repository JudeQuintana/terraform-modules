# Pull region data and account id from provider
data "aws_caller_identity" "this_one" {
  provider = aws.one
}

data "aws_region" "this_one" {
  provider = aws.one
}

data "aws_caller_identity" "this_two" {
  provider = aws.two
}

data "aws_region" "this_two" {
  provider = aws.two
}

data "aws_caller_identity" "this_three" {
  provider = aws.three
}

data "aws_region" "this_three" {
  provider = aws.three
}

locals {
  one_account_id   = data.aws_caller_identity.this_one.account_id
  one_region_name  = data.aws_region.this_one.name
  one_region_label = lookup(var.region_az_labels, local.one_region_name)

  two_account_id   = data.aws_caller_identity.this_two.account_id
  two_region_name  = data.aws_region.this_two.name
  two_region_label = lookup(var.region_az_labels, local.two_region_name)

  three_account_id   = data.aws_caller_identity.this_three.account_id
  three_region_name  = data.aws_region.this_three.name
  three_region_label = lookup(var.region_az_labels, local.three_region_name)

  upper_env_prefix = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)

  # fix naming later, probably pass thru
  base_full_mesh_trio_name  = format("%s-%s", local.upper_env_prefix, "full-mesh-trio")
  one_full_mesh_trio_name   = format("%s-%s-%s", local.base_full_mesh_trio_name, var.full_mesh_trio.one.centralized_router.name, local.one_region_label)
  two_full_mesh_trio_name   = format("%s-%s-%s", local.base_full_mesh_trio_name, var.full_mesh_trio.two.centralized_router.name, local.two_region_label)
  three_full_mesh_trio_name = format("%s-%s-%s", local.base_full_mesh_trio_name, var.full_mesh_trio.three.centralized_router.name, local.three_region_label)
}
