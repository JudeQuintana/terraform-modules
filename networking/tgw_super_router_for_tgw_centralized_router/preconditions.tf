locals {
  # used on both aws_ec2_transit_gateway.this_lcoal and aws_ec2_transit_gateway.this_peer
  # guarantee the centralized routers match their relative provider's region.
  local_provider_to_local_tgws_region_check = {
    condition     = alltrue([for region in local.local_tgws[*].region : contains([local.local_region_name], region)])
    error_message = "All local centralized router regions must match the aws.local provider alias region for Super Router."
  }

  peer_provider_to_peer_tgws_region_check = {
    condition     = alltrue([for region in local.peer_tgws[*].region : contains([local.peer_region_name], region)])
    error_message = "All peer centralized router regions must match the aws.peer provider alias region for Super Router."
  }
}
