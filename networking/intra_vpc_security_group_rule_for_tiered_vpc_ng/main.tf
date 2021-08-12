locals {
  # Each VPC id should have an inbound rule from all other VPC networks except itself
  # The next 3 for loops will build the following structure for local.vpc_id_to_inbound_networks
  # {
  #   vpc1_id = [vpc2_network, vpc3_network]
  #   vpc2_id = [vpc1_network, vpc3_network]
  #   vpc3_id = [vpc1_network, vpc2_network]
  #   ...
  # }
  # then use as a lookup table for local.vpc_to_intra_vpc_security_group_rules
  vpc_id_to_networks = { for vpc_name, this in var.vpcs : this.id => this.network }

  vpc_ids_vpc_networks_product = setproduct(
    keys(local.vpc_id_to_networks),
    values(local.vpc_id_to_networks)
  )

  vpc_id_to_inbound_networks = {
    for vpc_id_network in local.vpc_ids_vpc_networks_product :
    vpc_id_network[0] => vpc_id_network[1]...
    if lookup(local.vpc_id_to_networks, vpc_id_network[0]) != vpc_id_network[1]
  }

  # build a security group rule object for each vpc with vpc_name for the key
  vpc_to_intra_vpc_security_group_rules = {
    for vpc_name, this in var.vpcs :
    vpc_name => merge({
      intra_vpc_security_group_id = this.intra_vpc_security_group_id
      networks                    = lookup(local.vpc_id_to_inbound_networks, this.id)
    }, var.rule)
  }
}

resource "aws_security_group_rule" "this" {
  for_each = local.vpc_to_intra_vpc_security_group_rules

  security_group_id = each.value.intra_vpc_security_group_id
  cidr_blocks       = each.value.networks
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description = format(
    "%s Env: Allow %s inbound across VPCs",
    upper(var.env_prefix),
    each.value.label
  )
}
