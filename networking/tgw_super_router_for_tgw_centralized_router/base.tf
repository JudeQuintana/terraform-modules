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
  local_account_id   = data.aws_caller_identity.this_local.account_id
  local_region_name  = data.aws_region.this_local.name
  local_region_label = lookup(var.region_az_labels, local.local_region_name)

  peer_account_id   = data.aws_caller_identity.this_peer.account_id
  peer_region_name  = data.aws_region.this_peer.name
  peer_region_label = lookup(var.region_az_labels, local.peer_region_name)

  upper_env_prefix = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)

  base_super_router_name  = format("%s-%s", local.upper_env_prefix, "super-router")
  local_super_router_name = format("%s-%s-%s", local.base_super_router_name, var.super_router.name, local.local_region_label)
  peer_super_router_name  = format("%s-%s-%s", local.base_super_router_name, var.super_router.name, local.peer_region_label)
}

resource "aws_ec2_transit_gateway" "this_local" {
  provider = aws.local

  amazon_side_asn                 = var.super_router.local.amazon_side_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = merge(
    local.default_tags,
    { Name = local.local_super_router_name }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.local_provider_to_local_tgws_region_check.condition
      error_message = local.local_provider_to_local_tgws_region_check.error_message
    }

    precondition {
      condition     = local.local_provider_to_local_tgws_account_id_check.condition
      error_message = local.local_provider_to_local_tgws_account_id_check.error_message
    }

    precondition {
      condition     = local.peer_provider_to_peer_tgws_region_check.condition
      error_message = local.peer_provider_to_peer_tgws_region_check.error_message
    }

    precondition {
      condition     = local.peer_provider_to_peer_tgws_account_id_check.condition
      error_message = local.peer_provider_to_peer_tgws_account_id_check.error_message
    }
  }
}

resource "aws_ec2_transit_gateway" "this_peer" {
  provider = aws.peer

  amazon_side_asn                 = var.super_router.peer.amazon_side_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = merge(
    local.default_tags,
    { Name = local.peer_super_router_name }
  )

  lifecycle {
    # cant use dynamic block for lifecycle blocks
    # preconditions are evaluated only on apply
    # see preconditions.tf
    precondition {
      condition     = local.local_provider_to_local_tgws_region_check.condition
      error_message = local.local_provider_to_local_tgws_region_check.error_message
    }

    precondition {
      condition     = local.local_provider_to_local_tgws_account_id_check.condition
      error_message = local.local_provider_to_local_tgws_account_id_check.error_message
    }

    precondition {
      condition     = local.peer_provider_to_peer_tgws_region_check.condition
      error_message = local.peer_provider_to_peer_tgws_region_check.error_message
    }

    precondition {
      condition     = local.peer_provider_to_peer_tgws_account_id_check.condition
      error_message = local.peer_provider_to_peer_tgws_account_id_check.error_message
    }
  }
}
