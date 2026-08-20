
locals {
  reachability_matrix = { for this in [var.debug.reachability_matrix] : this => this if var.debug.reachability_matrix }

}
resource "local_file" "reachability_matrix" {
  for_each = local.reachability_matrix

  content  = jsonencode(module.this_generate_routes_to_other_vpcs.reachability)
  filename = format("%s/%s-reachability.json", path.root, local.centralized_router_name)
}
