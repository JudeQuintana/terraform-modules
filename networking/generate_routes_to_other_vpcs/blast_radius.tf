locals {
  vpc_route_table_count = {
    for name, vpc in var.generate_routes_to_other_vpcs.vpcs :
    name => length(vpc.private_route_table_ids) + length(vpc.public_route_table_ids)
  }

  vpc_cidr_count = {
    for name, vpc in var.generate_routes_to_other_vpcs.vpcs :
    name => 1 + length(vpc.secondary_cidrs)
  }

  blast_radius_changed_vpcs = local.has_previous ? distinct(flatten([
    for pair in concat(local.policy_diff.added, local.policy_diff.removed) : split(":", pair)
  ])) : []

  blast_radius_routes_per_added_pair = local.has_previous ? [
    for pair in local.policy_diff.added :
    lookup(local.vpc_route_table_count, element(split(":", pair), 0), 0) * lookup(local.vpc_cidr_count, element(split(":", pair), 1), 0)
    + lookup(local.vpc_route_table_count, element(split(":", pair), 1), 0) * lookup(local.vpc_cidr_count, element(split(":", pair), 0), 0)
  ] : []

  blast_radius_routes_per_removed_pair = local.has_previous ? [
    for pair in local.policy_diff.removed :
    lookup(local.vpc_route_table_count, element(split(":", pair), 0), 0) * lookup(local.vpc_cidr_count, element(split(":", pair), 1), 0)
    + lookup(local.vpc_route_table_count, element(split(":", pair), 1), 0) * lookup(local.vpc_cidr_count, element(split(":", pair), 0), 0)
  ] : []

  blast_radius_affected_route_table_ids = local.has_previous ? distinct(flatten([
    for vpc_name in local.blast_radius_changed_vpcs :
    concat(
      var.generate_routes_to_other_vpcs.vpcs[vpc_name].private_route_table_ids,
      var.generate_routes_to_other_vpcs.vpcs[vpc_name].public_route_table_ids
    ) if contains(keys(var.generate_routes_to_other_vpcs.vpcs), vpc_name)
  ])) : []

  blast_radius = local.has_previous ? {
    affected_vpcs         = sort(local.blast_radius_changed_vpcs)
    routes_added          = length(local.blast_radius_routes_per_added_pair) > 0 ? sum(local.blast_radius_routes_per_added_pair) : 0
    routes_removed        = length(local.blast_radius_routes_per_removed_pair) > 0 ? sum(local.blast_radius_routes_per_removed_pair) : 0
    pairs_changed         = length(local.policy_diff.added) + length(local.policy_diff.removed)
    route_tables_affected = length(local.blast_radius_affected_route_table_ids)
  } : null
}
