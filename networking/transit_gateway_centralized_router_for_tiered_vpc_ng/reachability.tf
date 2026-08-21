locals {
  reachability = { for this in [var.debug.reachability] : this => this if var.debug.reachability }
  diagnostics  = { for this in [var.debug.diagnostics] : this => this if var.debug.diagnostics }
  provenance   = { for this in [var.debug.provenance] : this => this if var.debug.provenance }
}

resource "local_file" "this_reachability" {
  for_each = local.reachability

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.reachability)
  filename = format("%s/%s-reachability.json", path.root, var.centralized_router.name)
}

resource "local_file" "this_diagnostics" {
  for_each = local.diagnostics

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.diagnostics)
  filename = format("%s/%s-diagnostics.json", path.root, var.centralized_router.name)
}

resource "local_file" "this_provenance" {
  for_each = local.provenance

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.provenance)
  filename = format("%s/%s-provenance.json", path.root, var.centralized_router.name)
}
