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
  # need lifecycle precondition here to make sure the peer links are up before adding the route.
  # otherwise have to double apply (1st error, 2nd success) in its current state.
  #│ Error: error creating EC2 Transit Gateway Route (tgw-rtb-06bc3ee428d3d8f34_10.0.0.0/20): IncorrectState: tgw-attach-036b94b7a33b579c2 is in invalid state
  #│       status code: 400, request id: d3a0e811-a7c3-4e93-811d-f1426547bf90
  #│
  #│   with module.tgw_super_router_usw2.aws_ec2_transit_gateway_route.local_this["tgw-0437861a2a09627bd"],
  #│   on .terraform/modules/tgw_super_router_usw2/routing.tf line 13, in resource "aws_ec2_transit_gateway_route" "local_this":
  #│   13: resource "aws_ec2_transit_gateway_route" "local_this" {
  #│
  #╵
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
  # need lifecycle precondition here to make sure the peer links are up before adding the route.
  # otherwise have to double apply (1st error, 2nd success) in its current state.
}

