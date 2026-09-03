locals {
  reachability              = { for this in [var.super_router.inspect.reachability] : this => this if var.super_router.inspect.reachability }
  diagnostics               = { for this in [var.super_router.inspect.diagnostics] : this => this if var.super_router.inspect.diagnostics }
  provenance                = { for this in [var.super_router.inspect.provenance] : this => this if var.super_router.inspect.provenance }
  previous_reachability     = var.super_router.inspect.policy_diff.previous_reachability != null
  policy_diff               = { for this in [local.previous_reachability] : this => this if local.previous_reachability }
  equivalent_routing_policy = var.super_router.inspect.equivalence.equivalent_routing_policy != null
  equivalence               = { for this in [local.equivalent_routing_policy] : this => this if local.equivalent_routing_policy }
  segment_report            = { for this in [var.super_router.inspect.segment_report] : this => this if var.super_router.inspect.segment_report }
  policy_normalization      = { for this in [var.super_router.inspect.policy_normalization] : this => this if var.super_router.inspect.policy_normalization }
  connectivity_graph        = { for this in [var.super_router.inspect.connectivity_graph] : this => this if var.super_router.inspect.connectivity_graph }
  has_assertions            = var.super_router.inspect.assertions != null
  assertions                = { for this in [local.has_assertions] : this => this if local.has_assertions }
}

resource "local_file" "this_reachability" {
  for_each = local.reachability

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.reachability)
  filename = format("%s/inspect/%s-reachability.json", path.root, local.super_router_name)
}

resource "local_file" "this_diagnostics" {
  for_each = local.diagnostics

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.diagnostics)
  filename = format("%s/inspect/%s-diagnostics.json", path.root, local.super_router_name)
}

resource "local_file" "this_provenance" {
  for_each = local.provenance

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.provenance)
  filename = format("%s/inspect/%s-provenance.json", path.root, local.super_router_name)
}

resource "local_file" "this_segment_report" {
  for_each = local.segment_report

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.segment_report)
  filename = format("%s/inspect/%s-segment-report.json", path.root, local.super_router_name)
}

resource "local_file" "this_policy_normalization" {
  for_each = local.policy_normalization

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.policy_normalization)
  filename = format("%s/inspect/%s-policy-normalization.json", path.root, local.super_router_name)
}

resource "local_file" "this_policy_diff" {
  for_each = local.policy_diff

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.policy_diff)
  filename = format("%s/inspect/%s-policy-diff.json", path.root, local.super_router_name)
}

resource "local_file" "this_equivalence" {
  for_each = local.equivalence

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.equivalence)
  filename = format("%s/inspect/%s-equivalence.json", path.root, local.super_router_name)
}

resource "local_file" "this_assertions" {
  for_each = local.assertions

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.assertions)
  filename = format("%s/inspect/%s-assertions.json", path.root, local.super_router_name)
}

resource "local_file" "this_blast_radius" {
  for_each = local.policy_diff

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.blast_radius)
  filename = format("%s/inspect/%s-blast-radius.json", path.root, local.super_router_name)
}

resource "local_file" "this_connectivity_graph" {
  for_each = local.connectivity_graph

  content  = module.this_generate_routes_to_other_vpcs.connectivity_graph
  filename = format("%s/inspect/%s-connectivity-graph.dot", path.root, local.super_router_name)
}
