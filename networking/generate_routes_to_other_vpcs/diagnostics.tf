locals {
  # VPCs with zero connectivity: all outbound verdicts are denied
  zero_connectivity_vpcs = [
    for name, vpc in var.vpcs : name
    if alltrue([
      for pair_key, verdict in local.reachability_with_duplicates : startswith(verdict, "denied")
      if startswith(pair_key, format("%s:", name))
    ]) && length(var.vpcs) > 1
  ]

  # single-member segments
  single_member_segments = [
    for segment_name, vpcs in var.routing_policy.segments : segment_name
    if length(vpcs) == 1
  ]

  # redundant deny rules: deny on a pair that would already be denied without it
  redundant_deny_rules = [
    for rule in var.routing_policy.deny : format(
      "%s -> %s",
      lookup(local.cidr_to_vpc_name, rule.from.network_cidr, rule.from.network_cidr),
      lookup(local.cidr_to_vpc_name, rule.to.network_cidr, rule.to.network_cidr)
    )
    if(
      var.routing_policy.default == "deny"
      && !contains(lookup(local.allow_lookup, rule.from.network_cidr, []), rule.to.network_cidr)
      && !contains(lookup(local.segment_permit_lookup, rule.from.network_cidr, []), rule.to.network_cidr)
    )
  ]

  # assemble diagnostics
  diagnostics = concat(
    [
      for name in local.zero_connectivity_vpcs :
      format("VPC \"%s\" has zero connectivity. It is unsegmented under default=\"deny\" with no allow rules.", name)
    ],
    [
      for name in local.single_member_segments :
      format("Segment \"%s\" contains only 1 VPC. Single-member segments have no routing effect under default=\"deny\".", name)
    ],
    [
      for pair in local.redundant_deny_rules :
      format("Deny rule { %s } is redundant: this pair would already be denied without it.", pair)
    ],
  )
}
