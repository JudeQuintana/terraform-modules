locals {
  pair_fmt = "%s:%s"
  vpc_pairs = flatten([
    for name, this in var.generate_routes_to_other_vpcs.vpcs : [
      for other_name, other_this in var.generate_routes_to_other_vpcs.vpcs : {
        from_name = name
        to_name   = other_name
        from_cidr = this.network_cidr
        to_cidr   = other_this.network_cidr
      } if name != other_name
  ]])

  # evaluate verdict per pair: deny > allow > segments > default
  reachability_combined = {
    for pair in local.vpc_pairs : format(local.pair_fmt, pair.from_name, pair.to_name) => (
      contains(lookup(local.deny_lookup, pair.from_cidr, []), pair.to_cidr)
      ? "denied:deny"
      : contains(lookup(local.allow_lookup, pair.from_cidr, []), pair.to_cidr)
      ? "permitted:allow"
      : contains(lookup(local.segment_permit_lookup, pair.from_cidr, []), pair.to_cidr)
      ? "permitted:segment"
      : var.generate_routes_to_other_vpcs.routing_policy.default == "allow"
      ? (contains(lookup(local.segment_deny_lookup, pair.from_cidr, []), pair.to_cidr)
        ? "denied:cross-segment"
      : "permitted:default")
      : "denied:default"
    )
  }

  # contains bidirectional duplicates: {from=app, to=db} and {from=db, to=app}
  reachability_with_bidirectional_duplicates = [
    for pair in local.vpc_pairs : {
      from    = pair.from_name
      to      = pair.to_name
      verdict = element(split(":", lookup(local.reachability_combined, format(local.pair_fmt, pair.from_name, pair.to_name))), 0)
      reason  = element(split(":", lookup(local.reachability_combined, format(local.pair_fmt, pair.from_name, pair.to_name))), 1)
    }
  ]

  # deduplicated: keep lexicographically-first pair only
  reachability = [
    for entry in local.reachability_with_bidirectional_duplicates : entry
    if format(local.pair_fmt, entry.from, entry.to) == join(":", sort([entry.from, entry.to]))
  ]

  reachability_lookup = {
    for entry in local.reachability :
    format(local.pair_fmt, entry.from, entry.to) => entry
  }

  reachability_bidirectional_lookup = {
    for entry in local.reachability_with_bidirectional_duplicates :
    format(local.pair_fmt, entry.from, entry.to) => entry
  }
}
