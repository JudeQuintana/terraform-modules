locals {
  # all VPC pairs (cartesian product, excluding self)
  vpc_pairs = flatten([
    for name, this in var.vpcs : [
      for other_name, other_this in var.vpcs : {
        key       = format("%s:%s", name, other_name)
        from_cidr = this.network_cidr
        to_cidr   = other_this.network_cidr
      } if name != other_name
  ]])

  # evaluate verdict per pair: deny > allow > segments > default
  reachability_with_duplicates = {
    for pair in local.vpc_pairs : pair.key => (
      contains(lookup(local.deny_lookup, pair.from_cidr, []), pair.to_cidr)
      ? "denied:deny"
      : contains(lookup(local.allow_lookup, pair.from_cidr, []), pair.to_cidr)
      ? "permitted:allow"
      : contains(lookup(local.segment_permit_lookup, pair.from_cidr, []), pair.to_cidr)
      ? "permitted:segment"
      : var.routing_policy.default == "allow"
      ? (contains(lookup(local.segment_deny_lookup, pair.from_cidr, []), pair.to_cidr)
        ? "denied:cross-segment"
      : "permitted:default")
      : "denied:default"
    )
  }

  # deduplicated: keep lexicographically-first key only ("app:db", not "db:app")
  reachability = {
    for k, v in local.reachability_with_duplicates : k => v
    if k == join(":", sort(split(":", k)))
  }
}
