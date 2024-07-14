# Pull caller identity data from provider
data "aws_caller_identity" "this" {}

# Pull region data from provider
data "aws_region" "this" {}

locals {
  account_id   = data.aws_caller_identity.this.account_id
  region_name  = data.aws_region.this.name
  region_label = lookup(var.region_az_labels, local.region_name)
  rule_type    = "ingress"
}

# Each VPC id should have an inbound rule from all other VPC networks except itself.
# ipv6
locals {
  vpc_id_to_ipv6_network_cidr = { for this in var.ipv6_intra_vpc_security_group_rule.vpcs : this.id => this.ipv6_network_cidr if this.ipv6_network_cidr != null }

  vpc_id_to_inbound_ipv6_network_cidrs = {
    for vpc_id_and_ipv6_network_cidr in setproduct(keys(local.vpc_id_to_ipv6_network_cidr), values(local.vpc_id_to_ipv6_network_cidr)) :
    vpc_id_and_ipv6_network_cidr[0] => vpc_id_and_ipv6_network_cidr[1]...
    if lookup(local.vpc_id_to_ipv6_network_cidr, vpc_id_and_ipv6_network_cidr[0]) != vpc_id_and_ipv6_network_cidr[1]
  }

  vpc_id_to_intra_vpc_ipv6_security_group_rule = {
    for this in var.ipv6_intra_vpc_security_group_rule.vpcs :
    this.id => merge(var.ipv6_intra_vpc_security_group_rule.rule, {
      intra_vpc_security_group_id = this.intra_vpc_security_group_id
      ipv6_network_cidrs          = lookup(local.vpc_id_to_inbound_ipv6_network_cidrs, this.id)
      type                        = local.rule_type
  }) }
}

resource "aws_security_group_rule" "this" {
  for_each = local.vpc_id_to_intra_vpc_ipv6_security_group_rule

  security_group_id = each.value.intra_vpc_security_group_id
  ipv6_cidr_blocks  = each.value.ipv6_network_cidrs
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description = format(
    "%s-%s: Allow %s inbound from other intra region VPCs in %s.",
    upper(var.env_prefix),
    local.region_label,
    each.value.label,
    local.region_label
  )

  lifecycle {
    # preconditions are evaluated on apply only.
    precondition {
      condition     = alltrue([for this in var.ipv6_intra_vpc_security_group_rule.vpcs : contains([local.account_id], this.account_id)])
      error_message = "All VPC account IDs must match the aws provider account ID for IPv6 Intra VPC Security Group Rules."
    }

    precondition {
      condition     = alltrue([for this in var.ipv6_intra_vpc_security_group_rule.vpcs : contains([local.region_name], this.region)])
      error_message = "All VPC regions must match the aws provider region for IPv6 Intra VPC Security Group Rules."
    }
  }
}
