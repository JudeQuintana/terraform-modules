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

  local_vpc_id_to_network_cidr = { for this in var.super_intra_vpc_security_group_rules.local.vpcs : this.id => this.network }
  peer_vpc_id_to_network_cidr  = { for this in var.super_intra_vpc_security_group_rules.peer.vpcs : this.id => this.network }

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

  #local_protocol_to_local_rules = { for vpc_id, this in var.intra_vpc_security_group_rule.local.vpc_id_to_rule : this.vpc_id => this }
  #peer_protocol_to_peer_rules = { for this in var.intra_vpc_security_group_rule.peer.all : this.vpc_id => this }

  #local_inbound_network_cidrs = distinct(values(local.local_vpc_id_to_local_networks_cidr))
  #peer_inbound_network_cidrs  = distinct(values(local.peer_vpc_id_to_local_networks_cidr))

  local_vpc_id_to_peer_intra_vpc_security_group_rules = {
    for vpc_id, this in local.local_vpc_id_to_peer_inbound_network_cidrs :
    vpc_id => merge(
      lookup(var.super_intra_vpc_security_group_rules.local.vpc_id_to_rule, vpc_id),
      { network_cidrs = this }
    )
  }

  peer_vpc_id_to_local_intra_vpc_security_group_rules = {
    for vpc_id, this in local.peer_vpc_id_to_local_inbound_network_cidrs :
    vpc_id => merge(
      lookup(var.intra_vpc_security_group_rule.local.vpc_id_to_rule, vpc_id),
      { network_cidrs = this }
    )
  }
}

resource "aws_security_group_rule" "this_local" {
  provider = aws.local

  for_each = local.local_vpc_id_to_peer_intra_vpc_security_group_rules

  security_group_id = each.value.intra_vpc_security_group_id
  cidr_blocks       = each.value.network_cidrs
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description = format(
    "%s Env: Allow %s-%s inbound across VPCs that are cross region.",
    upper(var.env_prefix),
    each.value.label,
    local.local_region_label
  )

  lifecycle {
    # preconditions are evaluated on apply only.
    precondition {
      condition     = local.local_provider_to_local_vpcs_region_check.condition
      error_message = local.local_provider_to_local_vpcs_region_check.error_message
    }

    precondition {
      condition     = local.peer_provider_to_peer_vpcs_region_check.condition
      error_message = local.peer_provider_to_peer_vpcs_region_check.error_message
    }

    precondition {
      condition     = local.local_provider_to_local_intra_vpc_sg_rule_region_check.condition
      error_message = local.local_provider_to_local_intra_vpc_sg_rule_region_check.error_message
    }

    precondition {
      condition     = local.peer_provider_to_peer_intra_vpc_sg_rule_region_check.condition
      error_message = local.peer_provider_to_peer_intra_vpc_sg_rule_region_check.error_message
    }
  }
}

resource "aws_security_group_rule" "this_peer" {
  provider = aws.peer

  for_each = local.peer_vpc_id_to_local_intra_vpc_security_group_rules

  security_group_id = each.value.intra_vpc_security_group_id
  cidr_blocks       = each.value.network_cidrs
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description = format(
    "%s Env: Allow %s-%s inbound across VPCs that are cross region.",
    upper(var.env_prefix),
    each.value.label,
    local.peer_region_label
  )

  lifecycle {
    # preconditions are evaluated on apply only.
    precondition {
      condition     = local.local_provider_to_local_vpcs_region_check.condition
      error_message = local.local_provider_to_local_vpcs_region_check.error_message
    }

    precondition {
      condition     = local.peer_provider_to_peer_vpcs_region_check.condition
      error_message = local.peer_provider_to_peer_vpcs_region_check.error_message
    }

    precondition {
      condition     = local.local_provider_to_local_intra_vpc_sg_rule_region_check.condition
      error_message = local.local_provider_to_local_intra_vpc_sg_rule_region_check.error_message
    }

    precondition {
      condition     = local.peer_provider_to_peer_intra_vpc_sg_rule_region_check.condition
      error_message = local.peer_provider_to_peer_intra_vpc_sg_rule_region_check.error_message
    }
  }
}
