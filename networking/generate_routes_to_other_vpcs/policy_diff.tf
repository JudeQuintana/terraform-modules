locals {
  has_previous = length(var.previous_reachability) > 0

  # deduplicate bidirectional pairs: keep lexicographically-first key only ("a:b", not "b:a")
  policy_diff = local.has_previous ? {
    added = [
      for k, v in local.reachability : k
      if startswith(v, "permitted")
      && !startswith(lookup(var.previous_reachability, k, "denied:"), "permitted")
      && k == join(":", sort(split(":", k)))
    ]
    removed = [
      for k, v in var.previous_reachability : k
      if startswith(v, "permitted")
      && !startswith(lookup(local.reachability, k, "denied:"), "permitted")
      && k == join(":", sort(split(":", k)))
    ]
    unchanged = [
      for k, v in local.reachability : k
      if v == lookup(var.previous_reachability, k, "")
      && k == join(":", sort(split(":", k)))
    ]
  } : {}
}
