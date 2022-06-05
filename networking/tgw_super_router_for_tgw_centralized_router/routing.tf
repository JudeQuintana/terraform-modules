locals {
  local_networks = flatten([
    for this in var.local_centralized_routers :
    [for vpc_name, vpc in this.vpcs : {
      vpc_network               = vpc.network
      tgw_id                    = this.id
      tgw_peering_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment.local_peers, this.id).id
      tgw_route_table_id        = this.route_table_id
    }]
  ])
}

resource "aws_ec2_transit_gateway_route" "local_this" {
  provider = aws.local

  for_each = { for r in local.local_networks : r.tgw_id => r }

  destination_cidr_block         = each.value.vpc_network
  transit_gateway_attachment_id  = each.value.tgw_peering_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id
}

locals {
  peer_networks = flatten([
    for this in var.peer_centralized_routers :
    [for vpc_name, vpc in this.vpcs : {
      vpc_network               = vpc.network
      tgw_id                    = this.id
      tgw_peering_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment.peer_peers, this.id).id
      tgw_route_table_id        = this.route_table_id
    }]
  ])
}

resource "aws_ec2_transit_gateway_route" "peer_this" {
  provider = aws.local

  for_each = { for r in local.peer_networks : r.tgw_id => r }

  destination_cidr_block         = each.value.vpc_network
  transit_gateway_attachment_id  = each.value.tgw_peering_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.local_this.id
}

