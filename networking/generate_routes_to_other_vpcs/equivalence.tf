locals {
  has_equivalent = var.equivalent_routing_policy != null

  # recompute lookups for equivalent policy (same algebra, different input)
  eq_deny_rules = local.has_equivalent ? [
    for rule in var.equivalent_routing_policy.deny : {
      from_cidrs = concat([rule.from.network_cidr], rule.from.secondary_cidrs)
      to_cidrs   = concat([rule.to.network_cidr], rule.to.secondary_cidrs)
  }] : []

  eq_allow_rules = local.has_equivalent ? [
    for rule in var.equivalent_routing_policy.allow : {
      from_cidrs = concat([rule.from.network_cidr], rule.from.secondary_cidrs)
      to_cidrs   = concat([rule.to.network_cidr], rule.to.secondary_cidrs)
  }] : []

  eq_segment_cidrs = local.has_equivalent ? [
    for vpcs in var.equivalent_routing_policy.segments : {
      cidrs = flatten([for vpc in vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)])
  }] : []

  eq_segment_deny_rules = flatten([
    for i, segment_a in local.eq_segment_cidrs : [
      for segment_b in slice(local.eq_segment_cidrs, i + 1, length(local.eq_segment_cidrs)) : {
        from_cidrs = segment_a.cidrs
        to_cidrs   = segment_b.cidrs
  }]])

  eq_deny_lookup = {
    for cidr in toset(flatten(concat(local.eq_deny_rules[*].from_cidrs, local.eq_deny_rules[*].to_cidrs))) :
    cidr => flatten([
      for rule in local.eq_deny_rules : concat(
        contains(rule.from_cidrs, cidr) ? rule.to_cidrs : [],
        contains(rule.to_cidrs, cidr) ? rule.from_cidrs : []
  )]) }

  eq_allow_lookup = {
    for cidr in toset(flatten(concat(local.eq_allow_rules[*].from_cidrs, local.eq_allow_rules[*].to_cidrs))) :
    cidr => flatten([
      for rule in local.eq_allow_rules : concat(
        contains(rule.from_cidrs, cidr) ? rule.to_cidrs : [],
        contains(rule.to_cidrs, cidr) ? rule.from_cidrs : []
  )]) }

  eq_segment_deny_lookup = {
    for cidr in toset(flatten(concat(local.eq_segment_deny_rules[*].from_cidrs, local.eq_segment_deny_rules[*].to_cidrs))) :
    cidr => flatten([
      for rule in local.eq_segment_deny_rules : concat(
        contains(rule.from_cidrs, cidr) ? rule.to_cidrs : [],
        contains(rule.to_cidrs, cidr) ? rule.from_cidrs : []
  )]) }

  eq_all_segmented_cidrs = toset(flatten(local.eq_segment_cidrs[*].cidrs))

  eq_segment_permit_lookup = {
    for cidr in local.eq_all_segmented_cidrs :
    cidr => flatten([
      for segment in local.eq_segment_cidrs :
      contains(segment.cidrs, cidr) ? segment.cidrs : []
  ]) }

  # evaluate verdict per pair using equivalent policy
  eq_reachability = local.has_equivalent ? {
    for pair in local.vpc_pairs : pair.key => (
      contains(lookup(local.eq_deny_lookup, pair.from_cidr, []), pair.to_cidr)
      ? "denied:deny"
      : contains(lookup(local.eq_allow_lookup, pair.from_cidr, []), pair.to_cidr)
      ? "permitted:allow"
      : contains(lookup(local.eq_segment_permit_lookup, pair.from_cidr, []), pair.to_cidr)
      ? "permitted:segment"
      : var.equivalent_routing_policy.default == "allow"
      ? (contains(lookup(local.eq_segment_deny_lookup, pair.from_cidr, []), pair.to_cidr)
        ? "denied:cross-segment"
      : "permitted:default")
      : "denied:default"
    )
  } : {}

  # compare: same permit/deny outcome for every pair (verdict reason is irrelevant)
  # deduplicate bidirectional pairs: keep lexicographically-first key only
  eq_mismatches = {
    for k, v in local.reachability : k => {
      routing_policy            = v
      equivalent_routing_policy = lookup(local.eq_reachability, k, "missing")
    } if local.has_equivalent
    && startswith(v, "permitted") != startswith(lookup(local.eq_reachability, k, "denied:"), "permitted")
    && k == join(":", sort(split(":", k)))
  }

  equivalence = local.has_equivalent ? {
    equivalent = length(local.eq_mismatches) == 0
    mismatches = local.eq_mismatches
  } : null
}
