locals {
  has_previous = var.generate_routes_to_other_vpcs.previous_reachability != null

  policy_diff = local.has_previous ? {
    added = [
      for vpc_name_pair, verdict_and_reason in local.reachability : vpc_name_pair
      if startswith(verdict_and_reason, "permitted")
      && !startswith(lookup(var.generate_routes_to_other_vpcs.previous_reachability, vpc_name_pair, "denied:"), "permitted")
    ]
    removed = [
      for vpc_name_pair, verdict_and_reason in var.generate_routes_to_other_vpcs.previous_reachability : vpc_name_pair
      if startswith(verdict_and_reason, "permitted")
      && !startswith(lookup(local.reachability, vpc_name_pair, "denied:"), "permitted")
      # deduplicated: keep lexicographically-first key only ("app:db", not "db:app")
      && vpc_name_pair == join(":", sort(split(":", vpc_name_pair)))
    ]
    unchanged = [
      for vpc_name_pair, verdict_and_reason in local.reachability : vpc_name_pair
      if verdict_and_reason == lookup(var.generate_routes_to_other_vpcs.previous_reachability, vpc_name_pair, "")
    ]
  } : {}
}
