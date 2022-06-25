# Create the Peering attachment in same region/acct for the local provider
# iteration of over centralized router in same region
locals {
  local_centralized_routers = { for this in var.local_centralized_routers : this.id => this }
}

resource "aws_ec2_transit_gateway_peering_attachment" "local_peers" {
  provider = aws.local

  for_each = local.local_centralized_routers

  peer_account_id         = each.value.account_id
  peer_region             = each.value.region
  peer_transit_gateway_id = each.key
  transit_gateway_id      = aws_ec2_transit_gateway.local_this.id
  tags = {
    Name = "same region tgw peer"
    Side = "Creator"
  }
}

# data source needed for intra-region peering.
# ref: https://github.com/hashicorp/terraform-provider-aws/issues/23828
data "aws_ec2_transit_gateway_peering_attachment" "local_acceptor_peering_data" {
  provider = aws.local

  for_each = local.local_centralized_routers

  filter {
    name   = "transit-gateway-id"
    values = [each.key]
  }

  depends_on = [aws_ec2_transit_gateway_peering_attachment.local_peers]
}

# accept it in the same region.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "local_locals" {
  provider = aws.local

  for_each = local.local_centralized_routers

  transit_gateway_attachment_id = lookup(data.aws_ec2_transit_gateway_peering_attachment.local_acceptor_peering_data, each.key).id
  tags = {
    Name = "same region tgw local"
    Side = "Acceptor"
  }

  #lifecycle {
  #ignore_changes = [transit_gateway_attachment_id]
  #}
  # might need ignore lifecycle on transit_gateway_id_attachment
  # (???) because if a non-force-destroy attribute is changed (???)
  # the data source wants to re-read settings and wants to force destroy
  # this resource. need to get more familiar with the data source behavior.
}

########################################################################

# Create the Peering attachment in cross region to super router (same acct) for the peer provider
locals {
  peer_centralized_routers = { for this in var.peer_centralized_routers : this.id => this }
}

resource "aws_ec2_transit_gateway_peering_attachment" "peer_peers" {
  provider = aws.local

  for_each = local.peer_centralized_routers

  peer_account_id         = each.value.account_id
  peer_region             = each.value.region
  peer_transit_gateway_id = each.key
  transit_gateway_id      = aws_ec2_transit_gateway.local_this.id
  tags = {
    Name = "cross region tgw peer"
    Side = "Creator"
  }
}

# accept it in cross region.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "peer_locals" {
  provider = aws.peer

  for_each = local.peer_centralized_routers

  transit_gateway_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment.peer_peers, each.key).id
  tags = {
    Name = "cross region tgw peer"
    Side = "Acceptor"
  }
}