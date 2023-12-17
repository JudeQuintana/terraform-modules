locals {
  # for some strange reason when the vpc peering is inter region
  # the tags for aws_vpc_peering_connection and aws_vpc_peering_connection_accepter will stomp on each other if they are different (not exaclty the same)
  # leading to an endless drift and non idempodent state
  # happens for both aws 4.x and 5.x providers
  # this doesnt happen if the vpc peering is cross region so it must be a bug in the provider
  # nor do any other resources have this issue (ie aws_vpc_route)
  # have to code around it when setting the Side tag and keeping the Name exaclty the same.
  # super annoying but whatever
  is_inter_region_vpc_peering = var.vpc_peering_deluxe.local.vpc.region == var.vpc_peering_deluxe.peer.vpc.region
  peering_name_format         = "%s <-> %s"
}

resource "aws_vpc_peering_connection" "this_local_to_this_peer" {
  provider = aws.local

  vpc_id        = var.vpc_peering_deluxe.local.vpc.id
  peer_region   = var.vpc_peering_deluxe.peer.vpc.region
  peer_vpc_id   = var.vpc_peering_deluxe.peer.vpc.id
  peer_owner_id = var.vpc_peering_deluxe.peer.vpc.account_id

  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, var.vpc_peering_deluxe.local.vpc.full_name, var.vpc_peering_deluxe.peer.vpc.full_name)
      Side = local.is_inter_region_vpc_peering ? "Peered" : "Local Creator"
    }
  )

  lifecycle {
    precondition {
      condition     = local.local_vpc_provider_region_check.condition
      error_message = local.local_vpc_provider_region_check.error_message
    }

    precondition {
      condition     = local.local_vpc_provider_account_id_check.condition
      error_message = local.local_vpc_provider_account_id_check.error_message
    }

    precondition {
      condition     = local.peer_vpc_provider_region_check.condition
      error_message = local.peer_vpc_provider_region_check.error_message
    }

    precondition {
      condition     = local.peer_vpc_provider_account_id_check.condition
      error_message = local.peer_vpc_provider_account_id_check.error_message
    }
  }
}

resource "aws_vpc_peering_connection_accepter" "this_local_to_this_peer" {
  provider = aws.peer

  vpc_peering_connection_id = aws_vpc_peering_connection.this_local_to_this_peer.id
  auto_accept               = true
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, var.vpc_peering_deluxe.local.vpc.full_name, var.vpc_peering_deluxe.peer.vpc.full_name)
      Side = local.is_inter_region_vpc_peering ? "Peered" : "Peer Accepter"
    }
  )
}

# connection options
# https://registry.terraform.io/providers/hashicorp/aws/4.67.0/docs/resources/vpc_peering_connection_options
# Docs say not to use aws_vpc_peering_connection_options with aws_vpc_peering_connection but this is apprently how you do it (in 4.x aws provider)
# :shruglife:
locals {
  vpc_peering_connection_options = { for this in [var.vpc_peering_deluxe.allow_remote_vpc_dns_resolution] : this => this if var.vpc_peering_deluxe.allow_remote_vpc_dns_resolution }
}

resource "aws_vpc_peering_connection_options" "this_local" {
  provider = aws.local

  for_each = local.vpc_peering_connection_options

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.this_local_to_this_peer.id

  requester {
    allow_remote_vpc_dns_resolution = each.value
  }
}

resource "aws_vpc_peering_connection_options" "this_peer" {
  provider = aws.peer

  for_each = local.vpc_peering_connection_options

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.this_local_to_this_peer.id

  accepter {
    allow_remote_vpc_dns_resolution = each.value
  }
}

