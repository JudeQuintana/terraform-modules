locals {
  # ipv4 deny policy
  # normalize each deny rule's VPC objects into full CIDR lists per side
  # ie { from_vpc = module.vpcs["app"], to_vpc = module.vpcs["cicd"] } becomes
  # { from_cidrs = ["10.0.0.0/20", ...secondaries], to_cidrs = ["172.16.0.0/20", ...secondaries] }
  deny_rules = [
    for rule in var.policy.deny : {
      from_cidrs = concat([rule.from_vpc.network_cidr], rule.from_vpc.secondary_cidrs)
      to_cidrs   = concat([rule.to_vpc.network_cidr], rule.to_vpc.secondary_cidrs)
    }
  ]

  # segments policy
  # normalize each segment's VPCs into full CIDR lists
  # ie segments = [{ name = "trusted", vpcs = [module.vpcs["app"], module.vpcs["cicd"]] }] becomes
  # [{ name = "trusted", cidrs = ["10.0.0.0/20", "10.1.0.0/20", "172.16.0.0/20"] }]
  segment_cidrs = [
    for segment in var.policy.segments : {
      name  = segment.name
      cidrs = flatten([for vpc in segment.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)])
    }
  ]

  # generate cross-segment deny rules: VPCs in different segments cannot reach each other.
  # for each pair of segments, create a deny rule from every CIDR in one to every CIDR in the other.
  # unsegmented VPCs are not affected (they route to everything).
  segment_deny_rules = flatten([
    for i, seg_a in local.segment_cidrs : [
      for seg_b in slice(local.segment_cidrs, i + 1, length(local.segment_cidrs)) : {
        from_cidrs = seg_a.cidrs
        to_cidrs   = seg_b.cidrs
      }
    ]
  ])

  # merge explicit deny rules with segment-derived deny rules
  all_deny_rules = concat(local.deny_rules, local.segment_deny_rules)

  # build the deny graph: for each CIDR that participates in any deny rule,
  # compute all CIDRs it cannot reach. bidirectional — if A denies B, then B also denies A.
  # only CIDRs mentioned in deny rules get entries (sparse map).
  deny_lookup = {
    for cidr in toset(flatten(concat(local.all_deny_rules[*].from_cidrs, local.all_deny_rules[*].to_cidrs))) :
    cidr => flatten([
      for rule in local.all_deny_rules : concat(
        contains(rule.from_cidrs, cidr) ? rule.to_cidrs : [],
        contains(rule.to_cidrs, cidr) ? rule.from_cidrs : []
      )
    ])
  }

  # resolve the deny graph per VPC's primary CIDR.
  # default [] handles VPCs not mentioned in any deny rule (they have no restrictions).
  # element(this.network_cidrs, 0) is always the network cidrs even though secondary cidrs are grouped together during normalization
  denied_cidr_to_network_cidrs = {
    for this in local.network_cidrs_with_route_table_ids :
    element(this.network_cidrs, 0) => lookup(local.deny_lookup, element(this.network_cidrs, 0), [])
  }
}
