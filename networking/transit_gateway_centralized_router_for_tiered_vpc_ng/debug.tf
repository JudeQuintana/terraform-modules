locals {
  reachability = { for this in [var.debug.reachability] : this => this if var.debug.reachability }
  diagnostics  = { for this in [var.debug.diagnostics] : this => this if var.debug.diagnostics }
  provenance   = { for this in [var.debug.provenance] : this => this if var.debug.provenance }
  policy_diff  = { for this in [var.debug.policy_diff] : this => this if var.debug.policy_diff }
  equivalence  = { for this in [var.debug.equivalence] : this => this if var.debug.equivalence }
}

resource "local_file" "this_reachability" {
  for_each = local.reachability

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.reachability)
  filename = format("%s/debug-centralized-router-%s-reachability.json", path.root, var.centralized_router.name)
}

resource "local_file" "this_diagnostics" {
  for_each = local.diagnostics

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.diagnostics)
  filename = format("%s/debug-centralized-router-%s-diagnostics.json", path.root, var.centralized_router.name)
}

resource "local_file" "this_provenance" {
  for_each = local.provenance

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.provenance)
  filename = format("%s/debug-centralized-router-%s-provenance.json", path.root, var.centralized_router.name)
}

resource "local_file" "this_policy_diff" {
  for_each = local.policy_diff

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.policy_diff)
  filename = format("%s/debug-centralized-router-%s-policy-diff.json", path.root, var.centralized_router.name)
}

resource "local_file" "this_equivalence" {
  for_each = local.equivalence

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.equivalence)
  filename = format("%s/debug-centralized-router-%s-equivalence.json", path.root, var.centralized_router.name)
}
