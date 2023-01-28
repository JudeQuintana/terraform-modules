locals {
  # used on both aws_ec2_transit_gateway.this_lcoal and aws_ec2_transit_gateway.this_peer
  # guarantee the centralized routers match their relative provider's region.
  local_provider_to_local_tgws_region_check = {
    condition     = alltrue([for this in local.local_tgws[*].region : contains([local.local_region_name], this)])
    error_message = "All local Centralized Router regions must match the aws.local provider alias region for Super Router."
  }

  local_provider_to_local_tgws_account_id_check = {
    condition     = alltrue([for this in local.local_tgws[*].account_id : contains([local.local_account_id], this)])
    error_message = "All local Centralized Router account IDs must match the aws.local provider alias account ID for Super Router."
  }

  peer_provider_to_peer_tgws_region_check = {
    condition     = alltrue([for this in local.peer_tgws[*].region : contains([local.peer_region_name], this)])
    error_message = "All peer Centralized Router regions must match the aws.peer provider alias region for Super Router."
  }

  peer_provider_to_peer_tgws_account_id_check = {
    condition     = alltrue([for this in local.peer_tgws[*].account_id : contains([local.peer_account_id], this)])
    error_message = "All peer Centralized Router account IDs must match the aws.peer provider alias account ID for Super Router."
  }
}
