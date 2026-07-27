locals {
  # ipv4 deny policy
  # normalize each deny rule's VPC objects into full CIDR lists per side
  # ie { from = module.vpcs["app"], to = module.vpcs["cicd"] } becomes
  # { from_cidrs = ["10.0.0.0/20", ...secondaries], to_cidrs = ["172.16.0.0/20", ...secondaries] }
  deny_rules = [
    for rule in var.policy.deny : {
      from_cidrs = concat([rule.from.network_cidr], rule.from.secondary_cidrs)
      to_cidrs   = concat([rule.to.network_cidr], rule.to.secondary_cidrs)
    }
  ]

  # build the deny graph: for each CIDR that participates in any deny rule,
  # compute all CIDRs it cannot reach. bidirectional — if A denies B, then B also denies A.
  # only CIDRs mentioned in deny rules get entries (sparse map).
  deny_lookup = {
    for cidr in toset(flatten(concat(local.deny_rules[*].from_cidrs, local.deny_rules[*].to_cidrs))) :
    cidr => flatten([
      for rule in local.deny_rules : concat(
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
