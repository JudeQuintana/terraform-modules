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
  local_networks = flatten(
    [for this in var.local_centralized_routers :
      [for vpc_name, vpc in this.vpcs : {
        vpc_network               = vpc.network
        tgw_id                    = this.id
        tgw_peering_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment.local_peers, this.id).id
        tgw_route_table_id        = this.route_table_id
  }]])
}

resource "aws_ec2_transit_gateway_route" "local_this" {
  provider = aws.local

  for_each = { for r in local.local_networks : r.tgw_id => r }

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

  for_each = { for r in local.local_networks : r.tgw_id => r }

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.local_peers, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id
}
#
# You cannot propagate a peering attachment to a Transit Gateway Route Table
#resource "aws_ec2_transit_gateway_route_table_propagation" "local_this" {
#provider = aws.local

#for_each = { for r in local.local_networks : r.tgw_id => r }

#transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.local_peers, each.key).id
#transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id
#}

locals {
  peer_networks = flatten(
    [for this in var.peer_centralized_routers :
      [for vpc_name, vpc in this.vpcs : {
        vpc_network               = vpc.network
        tgw_id                    = this.id
        tgw_peering_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment.peer_peers, this.id).id
        tgw_route_table_id        = this.route_table_id
  }]])
}

resource "aws_ec2_transit_gateway_route" "peer_this" {
  provider = aws.local

  for_each = { for r in local.peer_networks : r.tgw_id => r }

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

  for_each = { for r in local.peer_networks : r.tgw_id => r }

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.peer_peers, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id
}

