locals {
  # Each VPC id should have an inbound rule from all other VPC networks except itself.

  # { vpc1-id => "vpc1-network-cidr", vpc2-id => "vpc2-network-cidr", vpc3-id => "vpc3-network-cidr" }
  vpc_id_to_network_cidr = { for this in var.vpcs : this.id => this.network_cidr }

  # { vpc1-id = ["vpc2-network", "vpc3-network", ...], vpc2-id = ["vpc1-network", "vpc3-network", ...], vpc3-id = ["vpc1-network", "vpc2-network", ...] ...  }
  vpc_id_to_inbound_network_cidrs = {
    for vpc_id_and_network_cidr in setproduct(keys(local.vpc_id_to_network_cidr), values(local.vpc_id_to_network_cidr)) :
    vpc_id_and_network_cidr[0] => vpc_id_and_network_cidr[1]...
    if lookup(local.vpc_id_to_network_cidr, vpc_id_and_network_cidr[0]) != vpc_id_and_network_cidr[1]
  }

  # complete the security group rule object for each vpc
  vpc_name_to_intra_vpc_security_group_rules = {
    for this in var.vpcs :
    this.name => merge({
      intra_vpc_security_group_id = this.intra_vpc_security_group_id
      network_cidrs               = lookup(local.vpc_id_to_inbound_network_cidrs, this.id)
      type                        = "ingress"
    }, var.rule)
  }
}

resource "aws_security_group_rule" "this" {
  for_each = local.vpc_name_to_intra_vpc_security_group_rules

  security_group_id = each.value.intra_vpc_security_group_id
  cidr_blocks       = each.value.network_cidrs
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description = format(
    "%s Env: Allow %s inbound across VPCs",
    upper(var.env_prefix),
    each.value.label
  )
}
