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
  reachability = {
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

  # all IPv6 VPC pairs (only VPCs with IPv6 CIDRs)
  ipv6_vpc_pairs = flatten([
    for name, this in var.vpcs : [
      for other_name, other_this in var.vpcs : {
        key       = format("%s:%s", name, other_name)
        from_cidr = this.ipv6_network_cidr
        to_cidr   = other_this.ipv6_network_cidr
      } if name != other_name && other_this.ipv6_network_cidr != null
    ] if this.ipv6_network_cidr != null
  ])

  # evaluate IPv6 verdict per pair: deny > allow > segments > default
  ipv6_reachability = {
    for pair in local.ipv6_vpc_pairs : pair.key => (
      contains(lookup(local.ipv6_deny_lookup, pair.from_cidr, []), pair.to_cidr)
      ? "denied:deny"
      : contains(lookup(local.ipv6_allow_lookup, pair.from_cidr, []), pair.to_cidr)
      ? "permitted:allow"
      : contains(lookup(local.ipv6_segment_permit_lookup, pair.from_cidr, []), pair.to_cidr)
      ? "permitted:segment"
      : var.routing_policy.default == "allow"
      ? (contains(lookup(local.ipv6_segment_deny_lookup, pair.from_cidr, []), pair.to_cidr)
        ? "denied:cross-segment"
      : "permitted:default")
      : "denied:default"
    )
  }
}
