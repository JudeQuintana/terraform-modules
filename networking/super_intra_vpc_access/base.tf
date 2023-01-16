# Pull region data and account id from provider
data "aws_caller_identity" "this_local_current" {
  provider = aws.local
}

data "aws_region" "this_local_current" {
  provider = aws.local
}

data "aws_caller_identity" "this_peer_current" {
  provider = aws.peer
}

data "aws_region" "this_peer_current" {
  provider = aws.peer
}

locals {
  local_account_id   = data.aws_caller_identity.this_local_current.account_id
  local_region_name  = data.aws_region.this_local_current.name
  local_region_label = lookup(var.region_az_labels, local.local_region_name)

  peer_account_id   = data.aws_caller_identity.this_peer_current.account_id
  peer_region_name  = data.aws_region.this_peer_current.name
  peer_region_label = lookup(var.region_az_labels, local.peer_region_name)

  upper_env_prefix = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)
}
