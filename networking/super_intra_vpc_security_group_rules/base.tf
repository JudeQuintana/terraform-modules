# Pull region data and account id from provider
data "aws_caller_identity" "this_local_current" {
  provider = aws.local
}

data "aws_region" "this_local_current" {
  provider = aws.local
}

data "aws_caller_identity" "this_peer_current" {
  provider = aws.peer
}

data "aws_region" "this_peer_current" {
  provider = aws.peer
}

locals {
  local_account_id   = data.aws_caller_identity.this_local_current.account_id
  local_region_name  = data.aws_region.this_local_current.name
  local_region_label = lookup(var.region_az_labels, local.local_region_name)

  peer_account_id   = data.aws_caller_identity.this_peer_current.account_id
  peer_region_name  = data.aws_region.this_peer_current.name
  peer_region_label = lookup(var.region_az_labels, local.peer_region_name)

  upper_env_prefix = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  })

  local_vpc_id_to_network_cidr = merge([
    for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules : {
      for vpc in this.vpcs :
      vpc.id => vpc.network_cidr
  }]...)

  peer_vpc_id_to_network_cidr = merge([
    for this in var.super_intra_vpc_security_group_rules.peer.intra_vpc_security_group_rules : {
      for vpc in this.vpcs :
      vpc.id => vpc.network_cidr
  }]...)

  local_vpc_id_to_peer_inbound_network_cidrs = {
    for vpc_id_and_network_cidr in setproduct(keys(local.local_vpc_id_to_network_cidr), values(local.peer_vpc_id_to_network_cidr)) :
    vpc_id_and_network_cidr[0] => vpc_id_and_network_cidr[1]...
    if lookup(local.local_vpc_id_to_network_cidr, vpc_id_and_network_cidr[0]) != vpc_id_and_network_cidr[1]
  }

  peer_vpc_id_to_local_inbound_network_cidrs = {
    for vpc_id_and_network_cidr in setproduct(keys(local.peer_vpc_id_to_network_cidr), values(local.local_vpc_id_to_network_cidr)) :
    vpc_id_and_network_cidr[0] => vpc_id_and_network_cidr[1]...
    if lookup(local.peer_vpc_id_to_network_cidr, vpc_id_and_network_cidr[0]) != vpc_id_and_network_cidr[1]
  }

  local_rules = [for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules : this.rule]
  peer_rules  = [for this in var.super_intra_vpc_security_group_rules.peer.intra_vpc_security_group_rules : this.rule]

  local_vpc_id_to_intra_vpc_security_group_id = merge([
    for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules : {
      for vpc in this.vpcs :
      vpc.id => vpc.intra_vpc_security_group_id
  }]...)

  peer_vpc_id_to_intra_vpc_security_group_id = merge([
    for this in var.super_intra_vpc_security_group_rules.peer.intra_vpc_security_group_rules : {
      for vpc in this.vpcs :
      vpc.id => vpc.intra_vpc_security_group_id
  }]...)

  intra_vpc_security_group_rules_format = "%s|%s-%s-%s"

  local_vpc_id_and_rule_to_peer_intra_vpc_security_group_rule = merge([
    for rule in local.peer_rules : {
      for vpc_id, this in local.local_vpc_id_to_peer_inbound_network_cidrs :
      format(local.intra_vpc_security_group_rules_format, vpc_id, rule.protocol, rule.from_port.rule.to_port) => merge({
        intra_vpc_security_group_id = lookup(local.local_vpc_id_to_intra_vpc_security_group_id, vpc_id)
        network_cidrs               = this
        type                        = "ingress"
      }, rule)
    }
  ]...)

  peer_vpc_id_and_rule_to_local_intra_vpc_security_group_rule = merge([
    for rule in local.local_rules : {
      for vpc_id, this in local.peer_vpc_id_to_local_inbound_network_cidrs :
      format(local.intra_vpc_security_group_rules_format, vpc_id, rule.protocol, rule.from_port.rule.to_port) => merge({
        intra_vpc_security_group_id = lookup(local.peer_vpc_id_to_intra_vpc_security_group_id, vpc_id)
        network_cidrs               = this
        type                        = "ingress"
      }, rule)
    }
  ]...)
}

resource "aws_security_group_rule" "this_local" {
  provider = aws.local

  for_each = local.local_vpc_id_and_rule_to_peer_intra_vpc_security_group_rule

  security_group_id = each.value.intra_vpc_security_group_id
  cidr_blocks       = each.value.network_cidrs
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description = format(
    "%s-%s: Allow %s inbound from other cross region VPCs in %s.",
    upper(var.env_prefix),
    local.local_region_label,
    each.value.label,
    local.peer_region_label
  )

  lifecycle {
    # preconditions are evaluated on apply only.
    precondition {
      condition     = local.local_provider_to_local_intra_vpc_security_group_rules_region_check.condition
      error_message = local.local_provider_to_local_intra_vpc_security_group_rules_region_check.error_message
    }
    precondition {
      condition     = local.local_provider_to_local_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.local_provider_to_local_intra_vpc_security_group_rules_account_id_check.error_message
    }

    precondition {
      condition     = local.peer_provider_to_peer_intra_vpc_security_group_rules_region_check.condition
      error_message = local.peer_provider_to_peer_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.peer_provider_to_peer_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.peer_provider_to_peer_intra_vpc_security_group_rules_account_id_check.error_message
    }
  }
}

resource "aws_security_group_rule" "this_peer" {
  provider = aws.peer

  for_each = local.peer_vpc_id_and_rule_to_local_intra_vpc_security_group_rule

  security_group_id = each.value.intra_vpc_security_group_id
  cidr_blocks       = each.value.network_cidrs
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description = format(
    "%s-%s: Allow %s inbound from other cross region VPCs in %s.",
    upper(var.env_prefix),
    local.peer_region_label,
    each.value.label,
    local.local_region_label
  )

  lifecycle {
    # preconditions are evaluated on apply only.
    precondition {
      condition     = local.local_provider_to_local_intra_vpc_security_group_rules_region_check.condition
      error_message = local.local_provider_to_local_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.local_provider_to_local_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.local_provider_to_local_intra_vpc_security_group_rules_account_id_check.error_message
    }

    precondition {
      condition     = local.peer_provider_to_peer_intra_vpc_security_group_rules_region_check.condition
      error_message = local.peer_provider_to_peer_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.peer_provider_to_peer_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.peer_provider_to_peer_intra_vpc_security_group_rules_account_id_check.error_message
    }
  }
}
