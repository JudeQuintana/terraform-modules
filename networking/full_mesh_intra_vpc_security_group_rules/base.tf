# Pull region data and account id from provider
data "aws_caller_identity" "this_one" {
  provider = aws.one
}

data "aws_region" "this_one" {
  provider = aws.one
}

data "aws_caller_identity" "this_two" {
  provider = aws.two
}

data "aws_region" "this_two" {
  provider = aws.two
}

data "aws_caller_identity" "this_three" {
  provider = aws.three
}

data "aws_region" "this_three" {
  provider = aws.three
}

locals {
  one_account_id   = data.aws_caller_identity.this_one.account_id
  one_region_name  = data.aws_region.this_one.name
  one_region_label = lookup(var.region_az_labels, local.one_region_name)

  two_account_id   = data.aws_caller_identity.this_two.account_id
  two_region_name  = data.aws_region.this_two.name
  two_region_label = lookup(var.region_az_labels, local.two_region_name)

  three_account_id   = data.aws_caller_identity.this_three.account_id
  three_region_name  = data.aws_region.this_three.name
  three_region_label = lookup(var.region_az_labels, local.three_region_name)

  upper_env_prefix = upper(var.env_prefix)

  one_vpc_id_to_network_cidr = merge([
    for this in var.full_mesh_intra_vpc_security_group_rules.one.intra_vpc_security_group_rules : {
      for vpc in this.vpcs :
      vpc.id => vpc.network_cidr
  }]...)

  two_vpc_id_to_network_cidr = merge([
    for this in var.full_mesh_intra_vpc_security_group_rules.two.intra_vpc_security_group_rules : {
      for vpc in this.vpcs :
      vpc.id => vpc.network_cidr
  }]...)

  three_vpc_id_to_network_cidr = merge([
    for this in var.full_mesh_intra_vpc_security_group_rules.three.intra_vpc_security_group_rules : {
      for vpc in this.vpcs :
      vpc.id => vpc.network_cidr
  }]...)

  one_vpc_id_to_two_inbound_network_cidrs = {
    for vpc_id_and_network_cidr in setproduct(keys(local.one_vpc_id_to_network_cidr), values(local.two_vpc_id_to_network_cidr)) :
    vpc_id_and_network_cidr[0] => vpc_id_and_network_cidr[1]...
    if lookup(local.one_vpc_id_to_network_cidr, vpc_id_and_network_cidr[0]) != vpc_id_and_network_cidr[1]
  }

  one_vpc_id_to_three_inbound_network_cidrs = {
    for vpc_id_and_network_cidr in setproduct(keys(local.one_vpc_id_to_network_cidr), values(local.three_vpc_id_to_network_cidr)) :
    vpc_id_and_network_cidr[0] => vpc_id_and_network_cidr[1]...
    if lookup(local.one_vpc_id_to_network_cidr, vpc_id_and_network_cidr[0]) != vpc_id_and_network_cidr[1]
  }

  two_vpc_id_to_one_inbound_network_cidrs = {
    for vpc_id_and_network_cidr in setproduct(keys(local.two_vpc_id_to_network_cidr), values(local.one_vpc_id_to_network_cidr)) :
    vpc_id_and_network_cidr[0] => vpc_id_and_network_cidr[1]...
    if lookup(local.two_vpc_id_to_network_cidr, vpc_id_and_network_cidr[0]) != vpc_id_and_network_cidr[1]
  }

  two_vpc_id_to_three_inbound_network_cidrs = {
    for vpc_id_and_network_cidr in setproduct(keys(local.two_vpc_id_to_network_cidr), values(local.three_vpc_id_to_network_cidr)) :
    vpc_id_and_network_cidr[0] => vpc_id_and_network_cidr[1]...
    if lookup(local.two_vpc_id_to_network_cidr, vpc_id_and_network_cidr[0]) != vpc_id_and_network_cidr[1]
  }

  three_vpc_id_to_one_inbound_network_cidrs = {
    for vpc_id_and_network_cidr in setproduct(keys(local.three_vpc_id_to_network_cidr), values(local.one_vpc_id_to_network_cidr)) :
    vpc_id_and_network_cidr[0] => vpc_id_and_network_cidr[1]...
    if lookup(local.three_vpc_id_to_network_cidr, vpc_id_and_network_cidr[0]) != vpc_id_and_network_cidr[1]
  }

  three_vpc_id_to_two_inbound_network_cidrs = {
    for vpc_id_and_network_cidr in setproduct(keys(local.three_vpc_id_to_network_cidr), values(local.two_vpc_id_to_network_cidr)) :
    vpc_id_and_network_cidr[0] => vpc_id_and_network_cidr[1]...
    if lookup(local.three_vpc_id_to_network_cidr, vpc_id_and_network_cidr[0]) != vpc_id_and_network_cidr[1]
  }

  one_rules   = [for this in var.full_mesh_intra_vpc_security_group_rules.one.intra_vpc_security_group_rules : this.rule]
  two_rules   = [for this in var.full_mesh_intra_vpc_security_group_rules.two.intra_vpc_security_group_rules : this.rule]
  three_rules = [for this in var.full_mesh_intra_vpc_security_group_rules.three.intra_vpc_security_group_rules : this.rule]

  one_vpc_id_to_intra_vpc_security_group_id = merge([
    for this in var.full_mesh_intra_vpc_security_group_rules.one.intra_vpc_security_group_rules : {
      for vpc in this.vpcs :
      vpc.id => vpc.intra_vpc_security_group_id
  }]...)

  two_vpc_id_to_intra_vpc_security_group_id = merge([
    for this in var.full_mesh_intra_vpc_security_group_rules.two.intra_vpc_security_group_rules : {
      for vpc in this.vpcs :
      vpc.id => vpc.intra_vpc_security_group_id
  }]...)

  three_vpc_id_to_intra_vpc_security_group_id = merge([
    for this in var.full_mesh_intra_vpc_security_group_rules.three.intra_vpc_security_group_rules : {
      for vpc in this.vpcs :
      vpc.id => vpc.intra_vpc_security_group_id
  }]...)

  intra_vpc_security_group_rules_format = "%s|%s-%s-%s"
  intra_vpc_security_group_rule_type    = "ingress"

  one_vpc_id_and_rule_to_two_intra_vpc_security_group_rule = merge([
    for this in local.two_rules : {
      for vpc_id, inbound_network_cidrs in local.one_vpc_id_to_two_inbound_network_cidrs :
      format(local.intra_vpc_security_group_rules_format, vpc_id, this.protocol, this.from_port, this.to_port) => merge({
        intra_vpc_security_group_id = lookup(local.one_vpc_id_to_intra_vpc_security_group_id, vpc_id)
        network_cidrs               = inbound_network_cidrs
        type                        = local.intra_vpc_security_group_rule_type
      }, this)
  }]...)

  one_vpc_id_and_rule_to_three_intra_vpc_security_group_rule = merge([
    for this in local.three_rules : {
      for vpc_id, inbound_network_cidrs in local.one_vpc_id_to_three_inbound_network_cidrs :
      format(local.intra_vpc_security_group_rules_format, vpc_id, this.protocol, this.from_port, this.to_port) => merge({
        intra_vpc_security_group_id = lookup(local.one_vpc_id_to_intra_vpc_security_group_id, vpc_id)
        network_cidrs               = inbound_network_cidrs
        type                        = local.intra_vpc_security_group_rule_type
      }, this)
  }]...)

  two_vpc_id_and_rule_to_one_intra_vpc_security_group_rule = merge([
    for this in local.one_rules : {
      for vpc_id, inbound_network_cidrs in local.two_vpc_id_to_one_inbound_network_cidrs :
      format(local.intra_vpc_security_group_rules_format, vpc_id, this.protocol, this.from_port, this.to_port) => merge({
        intra_vpc_security_group_id = lookup(local.two_vpc_id_to_intra_vpc_security_group_id, vpc_id)
        network_cidrs               = inbound_network_cidrs
        type                        = local.intra_vpc_security_group_rule_type
      }, this)
  }]...)

  two_vpc_id_and_rule_to_three_intra_vpc_security_group_rule = merge([
    for this in local.three_rules : {
      for vpc_id, inbound_network_cidrs in local.two_vpc_id_to_three_inbound_network_cidrs :
      format(local.intra_vpc_security_group_rules_format, vpc_id, this.protocol, this.from_port, this.to_port) => merge({
        intra_vpc_security_group_id = lookup(local.two_vpc_id_to_intra_vpc_security_group_id, vpc_id)
        network_cidrs               = inbound_network_cidrs
        type                        = local.intra_vpc_security_group_rule_type
      }, this)
  }]...)

  three_vpc_id_and_rule_to_one_intra_vpc_security_group_rule = merge([
    for this in local.one_rules : {
      for vpc_id, inbound_network_cidrs in local.three_vpc_id_to_one_inbound_network_cidrs :
      format(local.intra_vpc_security_group_rules_format, vpc_id, this.protocol, this.from_port, this.to_port) => merge({
        intra_vpc_security_group_id = lookup(local.three_vpc_id_to_intra_vpc_security_group_id, vpc_id)
        network_cidrs               = inbound_network_cidrs
        type                        = local.intra_vpc_security_group_rule_type
      }, this)
  }]...)

  three_vpc_id_and_rule_to_two_intra_vpc_security_group_rule = merge([
    for this in local.two_rules : {
      for vpc_id, inbound_network_cidrs in local.three_vpc_id_to_two_inbound_network_cidrs :
      format(local.intra_vpc_security_group_rules_format, vpc_id, this.protocol, this.from_port, this.to_port) => merge({
        intra_vpc_security_group_id = lookup(local.three_vpc_id_to_intra_vpc_security_group_id, vpc_id)
        network_cidrs               = inbound_network_cidrs
        type                        = local.intra_vpc_security_group_rule_type
      }, this)
  }]...)
}

resource "aws_security_group_rule" "this_one_to_this_two" {
  provider = aws.one

  for_each = local.one_vpc_id_and_rule_to_two_intra_vpc_security_group_rule

  security_group_id = each.value.intra_vpc_security_group_id
  cidr_blocks       = each.value.network_cidrs
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description = format(
    "%s-%s: Allow %s inbound from other cross region VPCs in %s.",
    local.upper_env_prefix,
    local.one_region_label,
    each.value.label,
    local.two_region_label
  )

  lifecycle {
    precondition {
      condition     = local.one_provider_to_one_intra_vpc_security_group_rules_region_check.condition
      error_message = local.one_provider_to_one_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.one_provider_to_one_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.one_provider_to_one_intra_vpc_security_group_rules_account_id_check.error_message
    }

    precondition {
      condition     = local.two_provider_to_two_intra_vpc_security_group_rules_region_check.condition
      error_message = local.two_provider_to_two_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.two_provider_to_two_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.two_provider_to_two_intra_vpc_security_group_rules_account_id_check.error_message
    }

    precondition {
      condition     = local.three_provider_to_three_intra_vpc_security_group_rules_region_check.condition
      error_message = local.three_provider_to_three_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.three_provider_to_three_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.three_provider_to_three_intra_vpc_security_group_rules_account_id_check.error_message
    }
  }
}

resource "aws_security_group_rule" "this_one_to_this_three" {
  provider = aws.one

  for_each = local.one_vpc_id_and_rule_to_three_intra_vpc_security_group_rule

  security_group_id = each.value.intra_vpc_security_group_id
  cidr_blocks       = each.value.network_cidrs
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description = format(
    "%s-%s: Allow %s inbound from other cross region VPCs in %s.",
    local.upper_env_prefix,
    local.one_region_label,
    each.value.label,
    local.three_region_label
  )

  lifecycle {
    precondition {
      condition     = local.one_provider_to_one_intra_vpc_security_group_rules_region_check.condition
      error_message = local.one_provider_to_one_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.one_provider_to_one_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.one_provider_to_one_intra_vpc_security_group_rules_account_id_check.error_message
    }

    precondition {
      condition     = local.two_provider_to_two_intra_vpc_security_group_rules_region_check.condition
      error_message = local.two_provider_to_two_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.two_provider_to_two_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.two_provider_to_two_intra_vpc_security_group_rules_account_id_check.error_message
    }

    precondition {
      condition     = local.three_provider_to_three_intra_vpc_security_group_rules_region_check.condition
      error_message = local.three_provider_to_three_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.three_provider_to_three_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.three_provider_to_three_intra_vpc_security_group_rules_account_id_check.error_message
    }
  }
}

resource "aws_security_group_rule" "this_two_to_this_one" {
  provider = aws.two

  for_each = local.two_vpc_id_and_rule_to_one_intra_vpc_security_group_rule

  security_group_id = each.value.intra_vpc_security_group_id
  cidr_blocks       = each.value.network_cidrs
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description = format(
    "%s-%s: Allow %s inbound from other cross region VPCs in %s.",
    local.upper_env_prefix,
    local.two_region_label,
    each.value.label,
    local.one_region_label
  )

  lifecycle {
    precondition {
      condition     = local.one_provider_to_one_intra_vpc_security_group_rules_region_check.condition
      error_message = local.one_provider_to_one_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.one_provider_to_one_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.one_provider_to_one_intra_vpc_security_group_rules_account_id_check.error_message
    }

    precondition {
      condition     = local.two_provider_to_two_intra_vpc_security_group_rules_region_check.condition
      error_message = local.two_provider_to_two_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.two_provider_to_two_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.two_provider_to_two_intra_vpc_security_group_rules_account_id_check.error_message
    }

    precondition {
      condition     = local.three_provider_to_three_intra_vpc_security_group_rules_region_check.condition
      error_message = local.three_provider_to_three_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.three_provider_to_three_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.three_provider_to_three_intra_vpc_security_group_rules_account_id_check.error_message
    }
  }
}

resource "aws_security_group_rule" "this_two_to_this_three" {
  provider = aws.two

  for_each = local.two_vpc_id_and_rule_to_three_intra_vpc_security_group_rule

  security_group_id = each.value.intra_vpc_security_group_id
  cidr_blocks       = each.value.network_cidrs
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description = format(
    "%s-%s: Allow %s inbound from other cross region VPCs in %s.",
    local.upper_env_prefix,
    local.two_region_label,
    each.value.label,
    local.three_region_label
  )

  lifecycle {
    precondition {
      condition     = local.one_provider_to_one_intra_vpc_security_group_rules_region_check.condition
      error_message = local.one_provider_to_one_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.one_provider_to_one_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.one_provider_to_one_intra_vpc_security_group_rules_account_id_check.error_message
    }

    precondition {
      condition     = local.two_provider_to_two_intra_vpc_security_group_rules_region_check.condition
      error_message = local.two_provider_to_two_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.two_provider_to_two_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.two_provider_to_two_intra_vpc_security_group_rules_account_id_check.error_message
    }

    precondition {
      condition     = local.three_provider_to_three_intra_vpc_security_group_rules_region_check.condition
      error_message = local.three_provider_to_three_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.three_provider_to_three_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.three_provider_to_three_intra_vpc_security_group_rules_account_id_check.error_message
    }
  }
}

resource "aws_security_group_rule" "this_three_to_this_one" {
  provider = aws.three

  for_each = local.three_vpc_id_and_rule_to_one_intra_vpc_security_group_rule

  security_group_id = each.value.intra_vpc_security_group_id
  cidr_blocks       = each.value.network_cidrs
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description = format(
    "%s-%s: Allow %s inbound from other cross region VPCs in %s.",
    local.upper_env_prefix,
    local.three_region_label,
    each.value.label,
    local.one_region_label
  )

  lifecycle {
    precondition {
      condition     = local.one_provider_to_one_intra_vpc_security_group_rules_region_check.condition
      error_message = local.one_provider_to_one_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.one_provider_to_one_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.one_provider_to_one_intra_vpc_security_group_rules_account_id_check.error_message
    }

    precondition {
      condition     = local.two_provider_to_two_intra_vpc_security_group_rules_region_check.condition
      error_message = local.two_provider_to_two_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.two_provider_to_two_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.two_provider_to_two_intra_vpc_security_group_rules_account_id_check.error_message
    }

    precondition {
      condition     = local.three_provider_to_three_intra_vpc_security_group_rules_region_check.condition
      error_message = local.three_provider_to_three_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.three_provider_to_three_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.three_provider_to_three_intra_vpc_security_group_rules_account_id_check.error_message
    }
  }
}

resource "aws_security_group_rule" "this_three_to_this_two" {
  provider = aws.three

  for_each = local.three_vpc_id_and_rule_to_two_intra_vpc_security_group_rule

  security_group_id = each.value.intra_vpc_security_group_id
  cidr_blocks       = each.value.network_cidrs
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description = format(
    "%s-%s: Allow %s inbound from other cross region VPCs in %s.",
    local.upper_env_prefix,
    local.three_region_label,
    each.value.label,
    local.two_region_label
  )

  lifecycle {
    precondition {
      condition     = local.one_provider_to_one_intra_vpc_security_group_rules_region_check.condition
      error_message = local.one_provider_to_one_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.one_provider_to_one_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.one_provider_to_one_intra_vpc_security_group_rules_account_id_check.error_message
    }

    precondition {
      condition     = local.two_provider_to_two_intra_vpc_security_group_rules_region_check.condition
      error_message = local.two_provider_to_two_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.two_provider_to_two_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.two_provider_to_two_intra_vpc_security_group_rules_account_id_check.error_message
    }

    precondition {
      condition     = local.three_provider_to_three_intra_vpc_security_group_rules_region_check.condition
      error_message = local.three_provider_to_three_intra_vpc_security_group_rules_region_check.error_message
    }

    precondition {
      condition     = local.three_provider_to_three_intra_vpc_security_group_rules_account_id_check.condition
      error_message = local.three_provider_to_three_intra_vpc_security_group_rules_account_id_check.error_message
    }
  }
}

