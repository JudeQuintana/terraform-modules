locals {
  normalization_permitted_pairs = [
    for pair, verdict in local.reachability : pair
    if startswith(verdict, "permitted")
  ]

  normalization_denied_pairs = [
    for pair, verdict in local.reachability : pair
    if startswith(verdict, "denied")
  ]

  normalization_current_rule_count = (
    length(var.generate_routes_to_other_vpcs.routing_policy.deny)
    + length(var.generate_routes_to_other_vpcs.routing_policy.allow)
    + length(var.generate_routes_to_other_vpcs.routing_policy.segments)
  )

  # Reachability fingerprint: reach set including self.
  # VPCs with identical fingerprints have identical connectivity and are natural segment candidates.
  normalization_vpc_fingerprint = {
    for name in keys(var.generate_routes_to_other_vpcs.vpcs) : name => join(",", sort(concat(
      [name],
      [for other_name in keys(var.generate_routes_to_other_vpcs.vpcs) : other_name
       if other_name != name
       && startswith(lookup(local.reachability, join(":", sort([name, other_name])), "denied:default"), "permitted")
      ]
    )))
  }

  normalization_fingerprint_groups = {
    for fp in distinct(values(local.normalization_vpc_fingerprint)) :
    fp => sort([for name, f in local.normalization_vpc_fingerprint : name if f == fp])
  }

  normalization_segment_candidates = [
    for fp, members in local.normalization_fingerprint_groups : members
    if length(members) >= 2
  ]

  normalization_named_segments = {
    for idx, members in local.normalization_segment_candidates :
    format("group_%d", idx) => members
  }

  # Pairs covered by detected segments (upper triangle, no duplicates)
  normalization_segment_covered_pairs = toset(flatten([
    for members in local.normalization_segment_candidates : [
      for i, a in members : [
        for b in slice(members, i + 1, length(members)) :
        join(":", sort([a, b]))
      ]
    ]
  ]))

  # Permitted pairs not covered by any segment need explicit allow rules under default="deny"
  normalization_remaining_allow_pairs = [
    for pair in local.normalization_permitted_pairs : pair
    if !contains(local.normalization_segment_covered_pairs, pair)
  ]

  # Cost under each default
  normalization_deny_default_cost = (
    length(local.normalization_segment_candidates)
    + length(local.normalization_remaining_allow_pairs)
  )

  normalization_allow_default_cost = length(local.normalization_denied_pairs)

  normalization_suggested_default = (
    local.normalization_deny_default_cost <= local.normalization_allow_default_cost
    ? "deny" : "allow"
  )

  normalization_normalized_rule_count = (
    local.normalization_suggested_default == "deny"
    ? local.normalization_deny_default_cost
    : local.normalization_allow_default_cost
  )

  normalization_allow_rules = [
    for pair in local.normalization_remaining_allow_pairs : {
      from = element(split(":", pair), 0)
      to   = element(split(":", pair), 1)
    }
  ]

  normalization_deny_rules = [
    for pair in local.normalization_denied_pairs : {
      from = element(split(":", pair), 0)
      to   = element(split(":", pair), 1)
    }
  ]

  policy_normalization = {
    current_rule_count    = local.normalization_current_rule_count
    normalized_rule_count = local.normalization_normalized_rule_count
    normalized_policy = {
      default  = local.normalization_suggested_default
      segments = local.normalization_suggested_default == "deny" ? local.normalization_named_segments : {}
      allow    = local.normalization_suggested_default == "deny" ? local.normalization_allow_rules : []
      deny     = local.normalization_suggested_default == "allow" ? local.normalization_deny_rules : []
    }
  }
}
