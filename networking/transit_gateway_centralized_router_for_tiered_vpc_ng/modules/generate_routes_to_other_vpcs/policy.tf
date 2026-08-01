locals {
  # precedence (high to low):
  # 1. deny  -> always blocks
  # 2. allow -> always permits (overrides segments + default)
  # 3. segments -> same segment or unsegmented permits (overrides default)
  # 4. default -> fallthrough for anything unmatched ("allow" or "deny")

  # normalize deny rules into full CIDR lists per side
  # ie { from_vpc = module.vpcs["app"], to_vpc = module.vpcs["cicd"] } becomes
  # { from_cidrs = ["10.0.0.0/20", ...secondaries], to_cidrs = ["172.16.0.0/20", ...secondaries] }
  deny_rules = [
    for rule in var.policy.deny : {
      from_cidrs = concat([rule.from_vpc.network_cidr], rule.from_vpc.secondary_cidrs)
      to_cidrs   = concat([rule.to_vpc.network_cidr], rule.to_vpc.secondary_cidrs)
    }
  ]

  # normalize allow rules into full CIDR lists per side
  allow_rules = [
    for rule in var.policy.allow : {
      from_cidrs = concat([rule.from_vpc.network_cidr], rule.from_vpc.secondary_cidrs)
      to_cidrs   = concat([rule.to_vpc.network_cidr], rule.to_vpc.secondary_cidrs)
    }
  ]

  # normalize each segment's VPCs into full CIDR lists
  segment_cidrs = [
    for vpcs in var.policy.segments : {
      cidrs = flatten([for vpc in vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)])
    }
  ]

  # generate cross-segment deny rules: VPCs in different segments cannot reach each other.
  # unsegmented VPCs are not affected (they route to everything).
  #
  # produces one deny entry per unique segment pair (A↔B, A↔C, B↔C).
  # slice(list, i+1, end) restricts the inner loop to segments after the current one,
  # giving the upper-right triangle of the N×N matrix (no self-pairs, no duplicates).
  segment_deny_rules = flatten([
    for i, segment_a in local.segment_cidrs : [
      for segment_b in slice(local.segment_cidrs, i + 1, length(local.segment_cidrs)) : {
        from_cidrs = segment_a.cidrs
        to_cidrs   = segment_b.cidrs
      }
    ]
  ])

  # build the deny graph from explicit deny rules (highest precedence)
  deny_lookup = {
    for cidr in toset(flatten(concat(local.deny_rules[*].from_cidrs, local.deny_rules[*].to_cidrs))) :
    cidr => flatten([
      for rule in local.deny_rules : concat(
        contains(rule.from_cidrs, cidr) ? rule.to_cidrs : [],
        contains(rule.to_cidrs, cidr) ? rule.from_cidrs : []
      )
    ])
  }

  # build the allow graph (overrides segments + default)
  allow_lookup = {
    for cidr in toset(flatten(concat(local.allow_rules[*].from_cidrs, local.allow_rules[*].to_cidrs))) :
    cidr => flatten([
      for rule in local.allow_rules : concat(
        contains(rule.from_cidrs, cidr) ? rule.to_cidrs : [],
        contains(rule.to_cidrs, cidr) ? rule.from_cidrs : []
      )
    ])
  }

  # build the segment deny graph (cross-segment blocking, below allow in precedence)
  segment_deny_lookup = {
    for cidr in toset(flatten(concat(local.segment_deny_rules[*].from_cidrs, local.segment_deny_rules[*].to_cidrs))) :
    cidr => flatten([
      for rule in local.segment_deny_rules : concat(
        contains(rule.from_cidrs, cidr) ? rule.to_cidrs : [],
        contains(rule.to_cidrs, cidr) ? rule.from_cidrs : []
      )
    ])
  }

  all_segmented_cidrs = toset(flatten(local.segment_cidrs[*].cidrs))

  # segment permit: for each segmented CIDR, the list of CIDRs it can reach via segment membership.
  # same-segment CIDRs are always permitted regardless of default.
  segment_permit_lookup = {
    for cidr in local.all_segmented_cidrs :
    cidr => flatten([
      for segment in local.segment_cidrs :
      contains(segment.cidrs, cidr) ? segment.cidrs : []
    ])
  }

  # resolve the full precedence per VPC's primary CIDR.
  # for each VPC, compute the list of other CIDRs it is permitted to reach.
  # evaluation order: deny (block) > allow (permit) > segments (permit same-segment) > default
  network_cidr_to_other_network_cidrs = {
    for this in local.network_cidrs_with_route_table_ids :
    element(this.network_cidrs, 0) => [
      for n in flatten(local.network_cidrs_with_route_table_ids[*].network_cidrs) : n
      if !contains(this.network_cidrs, n)
      # 1. deny -> always blocks (highest precedence)
      && !contains(lookup(local.deny_lookup, element(this.network_cidrs, 0), []), n)
      # 2-4: allow > segments > default
      && (
        # 2. allow -> always permits (overrides segments + default)
        contains(lookup(local.allow_lookup, element(this.network_cidrs, 0), []), n)
        # 3. segments -> same segment permits (both source and target must be in the same segment)
        || contains(lookup(local.segment_permit_lookup, element(this.network_cidrs, 0), []), n)
        # 4. default -> fallthrough for anything not covered above
        || (
          var.policy.default == "allow"
          && !contains(lookup(local.segment_deny_lookup, element(this.network_cidrs, 0), []), n)
        )
      )
    ]
  }
}
