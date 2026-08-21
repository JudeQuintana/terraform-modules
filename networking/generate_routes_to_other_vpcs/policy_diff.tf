locals {
  has_previous = length(var.previous_reachability) > 0

  policy_diff = local.has_previous ? {
    added = [
      for k, v in local.reachability : k
      if startswith(v, "permitted") && !startswith(lookup(var.previous_reachability, k, "denied:"), "permitted")
    ]
    removed = [
      for k, v in var.previous_reachability : k
      if startswith(v, "permitted") && !startswith(lookup(local.reachability, k, "denied:"), "permitted")
    ]
    unchanged = [
      for k, v in local.reachability : k
      if v == lookup(var.previous_reachability, k, "")
    ]
  } : {}
}
