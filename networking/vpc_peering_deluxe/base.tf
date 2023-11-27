# Pull region data and account id from provider
data "aws_caller_identity" "this_local" {
  provider = aws.local
}

data "aws_region" "this_local" {
  provider = aws.local
}

data "aws_caller_identity" "this_peer" {
  provider = aws.peer
}

data "aws_region" "this_peer" {
  provider = aws.peer
}

locals {
  local_provider_account_id  = data.aws_caller_identity.this_local.account_id
  local_provider_region_name = data.aws_region.this_local.name

  peer_provider_account_id  = data.aws_caller_identity.this_peer.account_id
  peer_provider_region_name = data.aws_region.this_peer.name

  peering_name_format = "%s <-> %s"
  upper_env_prefix    = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)
}

