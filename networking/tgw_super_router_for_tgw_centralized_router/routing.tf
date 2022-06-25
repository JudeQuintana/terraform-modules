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
  local_tgws = [for this in var.local_centralized_routers : merge(
    this, { peering_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment.local_peers, this.id).id }
  )]

  #output "local_tgws_per_vpc_network" {
  #value = local.local_vpc_network_to_local_tgw
  #}

  local_vpc_network_to_local_tgw = merge(
    [for this in local.local_tgws :
      { for vpc_name, vpc in this.vpcs :
        vpc.network => this
  }]...)
}

resource "aws_ec2_transit_gateway_route" "local_this" {
  provider = aws.local

  for_each = local.local_vpc_network_to_local_tgw

  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = each.value.peering_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.local_locals]

  #lifecycle {
  #ignore_changes = [transit_gateway_attachment_id] ??
  #}
}

resource "aws_ec2_transit_gateway_route_table_association" "local_this" {
  provider = aws.local

  for_each = toset(local.local_tgws[*].id)

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

#resource "aws_route" "this" {
#for_each = module.generate_routes_to_other_vpcs.call

#destination_cidr_block = each.value
#route_table_id         = split("|", each.key)[0]
#transit_gateway_id     = aws_ec2_transit_gateway.this.id
#}

locals {
  peer_tgws = [for this in var.peer_centralized_routers :
    merge(this, { peering_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment.peer_peers, this.id).id }
  )]

  #output "peer_tgws_per_vpc_network" {
  #value = local.peer_tgws_per_vpc_network
  #}

  peer_vpc_network_to_peer_tgw = merge(
    [for this in local.peer_tgws :
      { for vpc_name, vpc in this.vpcs :
        vpc.network => this
  }]...)
}

resource "aws_ec2_transit_gateway_route" "peer_this" {
  provider = aws.local

  for_each = local.peer_vpc_network_to_peer_tgw

  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = each.value.peering_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id

  # make sure the peer links are up before adding the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.peer_locals]
  #lifecycle {
  #ignore_changes = [transit_gateway_attachment_id] ??
  #}
}

resource "aws_ec2_transit_gateway_route_table_association" "peer_this" {
  provider = aws.local

  for_each = toset(local.peer_tgws[*].id)

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.peer_peers, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id

  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.peer_locals]

  #lifecycle {
  #ignore_changes = [transit_gateway_attachment_id] ??
  #}
}

