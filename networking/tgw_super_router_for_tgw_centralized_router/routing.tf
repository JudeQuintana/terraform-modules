# one route table for all networks
resource "aws_ec2_transit_gateway_route_table" "local_this" {
  provider = aws.local

  transit_gateway_id = aws_ec2_transit_gateway.local_this.id
  tags = merge(
    local.default_tags,
    {
      Name = format("%s-%s-%s-%s", local.upper_env_prefix, "super-router", random_pet.this.id, local.local_region_label)
  })
}

locals {
  local_tgws_per_vpc_network = flatten(
    [for this in var.local_centralized_routers :
      [for vpc_name, vpc in this.vpcs : {
        vpc_network               = vpc.network
        tgw_id                    = this.id
        tgw_peering_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment.local_peers, this.id).id
        tgw_route_table_id        = this.route_table_id
  }]])

  vpc_network_to_local_tgw = { for this in local.local_tgws_per_vpc_network : this.vpc_network => this }
}


resource "aws_ec2_transit_gateway_route" "local_this" {
  provider = aws.local

  for_each = local.vpc_network_to_local_tgw

  destination_cidr_block         = each.value.vpc_network
  transit_gateway_attachment_id  = each.value.tgw_peering_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.local_locals]

  #lifecycle {
  #ignore_changes = [transit_gateway_attachment_id] ??
  #}
}

resource "aws_ec2_transit_gateway_route_table_association" "local_this" {
  provider = aws.local

  for_each = toset(var.local_centralized_routers[*].id)

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.local_peers, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id
  #
  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.local_locals]

  #lifecycle {
  #ignore_changes = [transit_gateway_attachment_id] ??
  #}
}
#
# You cannot propagate a tgw peering attachment to a Transit Gateway Route Table
# resource "aws_ec2_transit_gateway_route_table_propagation" "local_this" {}

# snippet
module "local_generate_routes_to_other_vpcs" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//utils/generate_routes_to_other_vpcs?ref=v1.3.0"

  for_each = { for this in var.local_centralized_routers : this.id => this.vpcs }

  vpcs = each.value
}

locals {
  generated_local = { for tgw_id, this in module.local_generate_routes_to_other_vpcs : tgw_id => this.call }
}

output "generated_local_vpc_routes" {
  value = local.generated_local
}

#resource "aws_route" "this" {
#for_each = module.generate_routes_to_other_vpcs.call

#destination_cidr_block = each.value
#route_table_id         = split("|", each.key)[0]
#transit_gateway_id     = aws_ec2_transit_gateway.this.id
#}

locals {
  peer_tgws_per_vpc_network = flatten(
    [for this in var.peer_centralized_routers :
      [for vpc_name, vpc in this.vpcs : {
        vpc_network               = vpc.network
        tgw_id                    = this.id
        tgw_peering_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment.peer_peers, this.id).id
        tgw_route_table_id        = this.route_table_id
  }]])

  vpc_network_to_peer_tgw = { for this in local.peer_tgws_per_vpc_network : this.vpc_network => this }
}

resource "aws_ec2_transit_gateway_route" "peer_this" {
  provider = aws.local

  for_each = local.vpc_network_to_peer_tgw

  destination_cidr_block         = each.value.vpc_network
  transit_gateway_attachment_id  = each.value.tgw_peering_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.peer_locals]
  #lifecycle {
  #ignore_changes = [transit_gateway_attachment_id] ??
  #}
}

resource "aws_ec2_transit_gateway_route_table_association" "peer_this" {
  provider = aws.local

  for_each = toset(var.peer_centralized_routers[*].id)

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.peer_peers, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id

  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.peer_locals]

  #lifecycle {
  #ignore_changes = [transit_gateway_attachment_id] ??
  #}
}

module "peer_generate_routes_to_other_vpcs" {
  source = "git@github.com:JudeQuintana/terraform-modules.git//utils/generate_routes_to_other_vpcs?ref=v1.3.0"

  for_each = { for this in var.peer_centralized_routers : this.id => this.vpcs }

  vpcs = each.value
}

locals {
  generated_peer = { for tgw_id, this in module.peer_generate_routes_to_other_vpcs : tgw_id => this.call }
}

output "generated_peer_vpc_routes" {
  value = local.generated_peer
}
