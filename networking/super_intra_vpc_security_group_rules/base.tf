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
  }, var.tags)

  local_vpc_id_to_local_networks_cidr = {
    for this in var.intra_vpc_security_group_rule.local.vpcs :
    this.id => this.network
  }

  peer_vpc_id_to_local_networks_cidr = {
    for this in var.intra_vpc_security_group_rule.peer.vpcs :
    this.id => this.network
  }

  local_vpc_id_to_local_rule = { for this in var.intra_vpc_security_group_rule.local.all : this.vpc_id => this }
  peer_vpc_id_to_peer_rule   = { for this in var.intra_vpc_security_group_rule.peer.all : this.vpc_id => this }

  local_inbound_network_cidrs = distinct(values(local.local_vpc_id_to_local_networks_cidr))
  peer_inbound_network_cidrs  = distinct(values(local.peer_vpc_id_to_local_networks_cidr))

  local_vpc_id_to_peer_intra_vpc_security_group_rules = {
    for this in var.intra_vpc_security_group_rule.peer.vpcs :
    this.id => merge(
      lookup(local.local_vpc_id_to_local_rule, this.id),
      { network_cidrs = local.peer_inbound_network_cidrs }
    )
  }

  peer_vpc_id_to_local_intra_vpc_security_group_rules = {
    for this in var.intra_vpc_security_group_rule.peer.vpcs :
    this.id => merge(
      lookup(local.peer_vpc_id_to_local_rule, this.id),
      { network_cidrs = local.local_inbound_network_cidrs }
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
    "%s Env: Allow %s-%s inbound across VPCs",
    upper(var.env_prefix),
    each.value.label,
    local.region_label
  )

  #lifecycle {
  ## preconditions are evaluated on apply only.
  #precondition {
  #condition     = alltrue([for this in var.intra_vpc_security_group_rule.vpcs : contains([local.region_name], this.region)])
  #error_message = "All VPC regions must match the aws provider region for Intra VPC Security Group Rules."
  #}
  #}
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
    "%s Env: Allow %s-%s inbound across VPCs",
    upper(var.env_prefix),
    each.value.label,
    local.region_label
  )

  lifecycle {
    # preconditions are evaluated on apply only.
    precondition {
      condition     = alltrue([for this in var.intra_vpc_security_group_rule.vpcs : contains([local.region_name], this.region)])
      error_message = "All VPC regions must match the aws provider region for Intra VPC Security Group Rules."
    }
  }
}
