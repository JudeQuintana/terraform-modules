locals {
  has_previous = length(var.generate_routes_to_other_vpcs.previous_reachability) > 0

  previous_reachability_lookup = {
    for entry in var.generate_routes_to_other_vpcs.previous_reachability :
    format(local.pair_fmt, entry.from, entry.to) => entry
  }

  policy_diff = local.has_previous ? {
    added = [
      for entry in local.reachability : format(local.pair_fmt, entry.from, entry.to)
      if entry.verdict == "permitted"
      && try(lookup(local.previous_reachability_lookup, format(local.pair_fmt, entry.from, entry.to)).verdict, "denied") != "permitted"
    ]
    removed = [
      for entry in var.generate_routes_to_other_vpcs.previous_reachability : format(local.pair_fmt, entry.from, entry.to)
      if entry.verdict == "permitted"
      && try(lookup(local.reachability_lookup, format(local.pair_fmt, entry.from, entry.to)).verdict, "denied") != "permitted"
      && format(local.pair_fmt, entry.from, entry.to) == join(":", sort([entry.from, entry.to]))
    ]
    unchanged = [
      for entry in local.reachability : format(local.pair_fmt, entry.from, entry.to)
      if entry.verdict == try(lookup(local.previous_reachability_lookup, format(local.pair_fmt, entry.from, entry.to)).verdict, "")
      && entry.reason == try(lookup(local.previous_reachability_lookup, format(local.pair_fmt, entry.from, entry.to)).reason, "")
    ]
  } : {}
}
