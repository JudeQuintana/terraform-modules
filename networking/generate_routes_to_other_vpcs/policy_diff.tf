locals {
  has_previous = var.generate_routes_to_other_vpcs.previous_reachability != null

  # deduplicate bidirectional pairs: keep lexicographically-first key only ("a:b", not "b:a")
  policy_diff = local.has_previous ? {
    added = [
      for k, v in local.reachability : k
      if startswith(v, "permitted")
      && !startswith(lookup(var.generate_routes_to_other_vpcs.previous_reachability, k, "denied:"), "permitted")
    ]
    removed = [
      for k, v in var.generate_routes_to_other_vpcs.previous_reachability : k
      if startswith(v, "permitted")
      && !startswith(lookup(local.reachability, k, "denied:"), "permitted")
      && k == join(":", sort(split(":", k)))
    ]
    unchanged = [
      for k, v in local.reachability : k
      if v == lookup(var.generate_routes_to_other_vpcs.previous_reachability, k, "")
    ]
  } : {}
}
