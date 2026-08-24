locals {
  reachability                           = { for this in [var.inspect.reachability] : this => this if var.inspect.reachability }
  diagnostics                            = { for this in [var.inspect.diagnostics] : this => this if var.inspect.diagnostics }
  provenance                             = { for this in [var.inspect.provenance] : this => this if var.inspect.provenance }
  policy_diff_is_populated               = length(var.inspect.policy_diff) > 0
  policy_diff                            = { for this in [local.policy_diff_is_populated] : this => this if local.policy_diff_is_populated }
  equivalent_routing_policy_is_populated = var.inspect.equivalence.equivalent_routing_policy != null
  equivalence                            = { for this in [local.equivalent_routing_policy_is_populated] : this => this if local.equivalent_routing_policy_is_populated }
}

resource "local_file" "this_reachability" {
  for_each = local.reachability

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.reachability)
  filename = format("%s/inspect-centralized-router-%s-reachability.json", path.root, var.centralized_router.name)
}

resource "local_file" "this_diagnostics" {
  for_each = local.diagnostics

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.diagnostics)
  filename = format("%s/inspect-centralized-router-%s-diagnostics.json", path.root, var.centralized_router.name)
}

resource "local_file" "this_provenance" {
  for_each = local.provenance

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.provenance)
  filename = format("%s/inspect-centralized-router-%s-provenance.json", path.root, var.centralized_router.name)
}

resource "local_file" "this_policy_diff" {
  for_each = local.policy_diff

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.policy_diff)
  filename = format("%s/inspect-centralized-router-%s-policy-diff.json", path.root, var.centralized_router.name)
}

resource "local_file" "this_equivalence" {
  for_each = local.equivalence

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.equivalence)
  filename = format("%s/inspect-centralized-router-%s-equivalence.json", path.root, var.centralized_router.name)
}
