locals {
  # generate top level networks for each tier based on tier newbit + base_cidr_block mask ie /4 + /16 = /20
  tier_networks = zipmap(var.tiers[*].name, cidrsubnets(var.base_cidr_block, var.tiers[*].newbit...))

  # generate a subnet based on az newbit per tier network ie /4 + /20 = /24
  tier_subnets = { for t, n in local.tier_networks : t => cidrsubnets(n, values(var.az_newbits)...) }

  # generate azs to subnet map per tier
  tier_az_subnets = { for t, s in local.tier_subnets : t => zipmap(keys(var.az_newbits), s) }

  # build new tiers list with their associated network and az to subnets map
  tiers_with_subnets_per_az = [
    for t in var.tiers : {
      name    = t.name
      acl     = t.acl
      network = lookup(local.tier_networks, t.name)
      azs     = lookup(local.tier_az_subnets, t.name)
  }]
}

output "calculated_tiers" {
  value = local.tiers_with_subnets_per_az
}

