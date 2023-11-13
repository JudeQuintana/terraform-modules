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

  base_full_mesh_trio_name  = format("%s-%s", local.upper_env_prefix, "full-mesh-trio")
  one_full_mesh_trio_name   = format("%s-%s-%s", local.base_full_mesh_trio_name, var.full_mesh_trio.one.centralized_router.name, local.one_region_label)
  two_full_mesh_trio_name   = format("%s-%s-%s", local.base_full_mesh_trio_name, var.full_mesh_trio.two.centralized_router.name, local.two_region_label)
  three_full_mesh_trio_name = format("%s-%s-%s", local.base_full_mesh_trio_name, var.full_mesh_trio.three.centralized_router.name, local.three_region_label)

  # gernate routes to other tgws
  # { vpc-1-network_cidr => [ "vpc-1-private-rtb-id-1", "vpc-1-public-rtb-id-1", ... ], ...}
  #vpc_network_cidr_to_route_table_ids = {
  #for this in var.vpcs :
  #this.network_cidr => concat(this.private_route_table_ids, this.public_route_table_ids)
  #}

  ## [ { rtb_id = "vpc-1-rtb-id-123", other_network_cidrs = [ "other-vpc-2-network_cidr", "other-vpc3-network_cidr", ... ] }, ...]
  #associate_route_table_ids_with_other_network_cidrs = flatten([
  #for network_cidr, route_table_ids in local.vpc_network_cidr_to_route_table_ids : [
  #for this in route_table_ids : {
  #route_table_id      = this
  #other_network_cidrs = [for n in keys(local.vpc_network_cidr_to_route_table_ids) : n if n != network_cidr]
  #}]])

  ## the better way to serve routes like hotcakes
  ## { route_table_id = "rtb-12345678", destination_cidr_block = "x.x.x.x/x" }
  ## need extra toset because there will be duplicates per AZ after the flatten call
  #routes = toset(flatten([
  #for this in local.associate_route_table_ids_with_other_network_cidrs : [
  #for route_table_id_and_network_cidr in setproduct([this.route_table_id], this.other_network_cidrs) : {
  #route_table_id         = route_table_id_and_network_cidr[0]
  #destination_cidr_block = route_table_id_and_network_cidr[1]
  #}]]))
}
