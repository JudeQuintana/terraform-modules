# Pull caller identity data from provider
data "aws_caller_identity" "current" {}

# Pull region data from provider
data "aws_region" "current" {}

locals {
  account_id   = data.aws_caller_identity.current.account_id
  region_name  = data.aws_region.current.name
  region_label = lookup(var.region_az_labels, local.region_name)

  # Each VPC id should have an inbound rule from all other VPC networks except itself.

  # { vpc1-id => "vpc1-network-cidr", vpc2-id => "vpc2-network-cidr", vpc3-id => "vpc3-network-cidr" }
  vpc_id_to_network_cidr = { for this in var.intra_vpc_security_group_rule.vpcs : this.id => this.network_cidr }

  # { vpc1-id = ["vpc2-network-cidr", "vpc3-network-cidr", ...], vpc2-id = ["vpc1-network-cidr", "vpc3-network-cidr", ...], vpc3-id = ["vpc1-network-cidr", "vpc2-network-cidr", ...] ...  }
  vpc_id_to_inbound_network_cidrs = {
    for vpc_id_and_network_cidr in setproduct(keys(local.vpc_id_to_network_cidr), values(local.vpc_id_to_network_cidr)) :
    vpc_id_and_network_cidr[0] => vpc_id_and_network_cidr[1]...
    if lookup(local.vpc_id_to_network_cidr, vpc_id_and_network_cidr[0]) != vpc_id_and_network_cidr[1]
  }

  # complete the security group rule object for each vpc
  vpc_id_to_intra_vpc_security_group_rules = {
    for this in var.intra_vpc_security_group_rule.vpcs :
    this.id => merge({
      intra_vpc_security_group_id = this.intra_vpc_security_group_id
      network_cidrs               = lookup(local.vpc_id_to_inbound_network_cidrs, this.id)
      type                        = "ingress"
      vpc_id                      = this.id # used for output
    }, var.intra_vpc_security_group_rule.rule)
  }
}

resource "aws_security_group_rule" "this" {
  for_each = local.vpc_id_to_intra_vpc_security_group_rules

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
