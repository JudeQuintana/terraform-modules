locals {
  has_assertions = var.generate_routes_to_other_vpcs.assertions != null

  must_deny_checks = local.has_assertions ? [
    for rule in var.generate_routes_to_other_vpcs.assertions.must_deny : {
      key = join(":", sort([
        lookup(local.cidr_to_vpc_name, rule.from.network_cidr, rule.from.network_cidr),
        lookup(local.cidr_to_vpc_name, rule.to.network_cidr, rule.to.network_cidr)
      ]))
    }
  ] : []

  must_permit_checks = local.has_assertions ? [
    for rule in var.generate_routes_to_other_vpcs.assertions.must_permit : {
      key = join(":", sort([
        lookup(local.cidr_to_vpc_name, rule.from.network_cidr, rule.from.network_cidr),
        lookup(local.cidr_to_vpc_name, rule.to.network_cidr, rule.to.network_cidr)
      ]))
    }
  ] : []

  must_deny_violations = [
    for check in local.must_deny_checks : {
      pair    = check.key
      verdict = lookup(local.reachability, check.key, "unknown")
    } if startswith(lookup(local.reachability, check.key, "denied:default"), "permitted")
  ]

  must_permit_violations = [
    for check in local.must_permit_checks : {
      pair    = check.key
      verdict = lookup(local.reachability, check.key, "unknown")
    } if startswith(lookup(local.reachability, check.key, "permitted:default"), "denied")
  ]

  assertions = local.has_assertions ? {
    passed = length(local.must_deny_violations) == 0 && length(local.must_permit_violations) == 0
    violations = {
      must_deny  = local.must_deny_violations
      must_permit = local.must_permit_violations
    }
  } : null
}
