# output routes as set of objects instead of a map
# it makes it easier to handle when passing to other route resource types (vpc, tgw)
# toset([{ route_table_id = "rtb-12345678", destination_cidr_block = "x.x.x.x/x" }, ...])
output "ipv4" {
  value = local.routes

  precondition {
    condition     = length(local.out_of_scope_rules) == 0
    error_message = "Routing policy references CIDRs not in var.vpcs: ${join(", ", local.out_of_scope_rules)}. Allow/deny rules can only reference VPCs in this router's scope."
  }
}

output "ipv6" {
  value = local.ipv6_routes
}

output "reachability" {
  value = local.reachability
}

output "diagnostics" {
  value = local.diagnostics
}

output "provenance" {
  value = local.provenance
}

output "policy_diff" {
  value = local.policy_diff
}

output "equivalence" {
  value = local.equivalence
}
