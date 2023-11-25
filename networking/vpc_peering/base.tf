locals {
  peering_name_format = "%s <-> %s"
  upper_env_prefix    = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)
}

resource "aws_vpc_peering_connection" "this_local_to_this_peer" {
  provider = aws.local

  vpc_id        = var.vpc_peering.local.vpc.id
  peer_region   = var.vpc_peering.peer.vpc.region
  peer_vpc_id   = var.vpc_peering.peer.vpc.id
  peer_owner_id = var.vpc_peering.peer.vpc.account_id

  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, var.vpc_peering.local.vpc.full_name, var.vpc_peering.peer.vpc.full_name)
      Side = "Local Creator"
    }
  )
}

# Accept VPC peering request
resource "aws_vpc_peering_connection_accepter" "this_local_to_this_peer" {
  provider = aws.peer

  vpc_peering_connection_id = aws_vpc_peering_connection.this_local_to_this_peer.id
  auto_accept               = true
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, var.vpc_peering.peer.vpc.full_name, var.vpc_peering.local.vpc.full_name)
      Side = "Peer Accepter"
    }
  )
}

