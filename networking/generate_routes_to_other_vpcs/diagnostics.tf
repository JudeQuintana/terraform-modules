locals {
  # VPCs with zero connectivity: all outbound verdicts are denied
  zero_connectivity_vpcs = [
    for name, vpc in var.generate_routes_to_other_vpcs.vpcs : name
    if alltrue([
      for vpc_name_pair, verdict_and_reason in local.reachability_with_bidirectional_duplicates : startswith(verdict_and_reason, "denied")
      if startswith(vpc_name_pair, format("%s:", name))
    ]) && length(var.generate_routes_to_other_vpcs.vpcs) > 1
  ]

  # single-member segments
  single_member_segments = [
    for segment_name, vpcs in var.generate_routes_to_other_vpcs.routing_policy.segments : segment_name
    if length(vpcs) == 1
  ]

  # redundant deny rules: deny on a pair that would already be denied without it
  redundant_deny_rules = [
    for rule in var.generate_routes_to_other_vpcs.routing_policy.deny : format(
      "%s -> %s",
      lookup(local.cidr_to_vpc_name, rule.from.network_cidr, rule.from.network_cidr),
      lookup(local.cidr_to_vpc_name, rule.to.network_cidr, rule.to.network_cidr)
    )
    if(
      var.generate_routes_to_other_vpcs.routing_policy.default == "deny"
      && !contains(lookup(local.allow_lookup, rule.from.network_cidr, []), rule.to.network_cidr)
      && !contains(lookup(local.segment_permit_lookup, rule.from.network_cidr, []), rule.to.network_cidr)
    )
  ]

  # single segment under default=allow has no routing effect (no other segment to deny against)
  single_segment_no_effect = (
    var.generate_routes_to_other_vpcs.routing_policy.default == "allow"
    && length(var.generate_routes_to_other_vpcs.routing_policy.segments) == 1
  )

  # redundant allow rules: allow on a pair that would already be permitted without it
  redundant_allow_rules = [
    for rule in var.generate_routes_to_other_vpcs.routing_policy.allow : format(
      "%s -> %s",
      lookup(local.cidr_to_vpc_name, rule.from.network_cidr, rule.from.network_cidr),
      lookup(local.cidr_to_vpc_name, rule.to.network_cidr, rule.to.network_cidr)
    )
    if(
      var.generate_routes_to_other_vpcs.routing_policy.default == "allow"
      && !contains(lookup(local.segment_deny_lookup, rule.from.network_cidr, []), rule.to.network_cidr)
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
    [
      for pair in local.redundant_allow_rules :
      format("Allow rule { %s } is redundant: this pair would already be permitted without it.", pair)
    ],
    local.single_segment_no_effect ? [
      format("Policy has 1 segment under default=\"allow\". A single segment has no routing effect when there is no other segment to deny against.")
    ] : [],
  )
}
