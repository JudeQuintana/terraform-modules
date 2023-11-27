locals {
  # guarantee the vpcs match their relative provider's region and account id before creating the vpc peering connections
  local_vpc_provider_region_check = {
    condition     = contains([local.local_provider_region_name], var.vpc_peering_deluxe.local.vpc.region)
    error_message = "The local VPC region must match the aws.local provider alias region for VPC Peering Deluxe."
  }

  local_vpc_provider_account_id_check = {
    condition     = contains([local.local_provider_account_id], var.vpc_peering_deluxe.local.vpc.account_id)
    error_message = "The local VPC account ID must match the aws.local provider alias account VPC Peering Deluxe."
  }

  peer_vpc_provider_region_check = {
    condition     = contains([local.peer_provider_region_name], var.vpc_peering_deluxe.peer.vpc.region)
    error_message = "The peer VPC region must match the aws.peer provider alias region for VPC Peering Deluxe."
  }

  peer_vpc_provider_account_id_check = {
    condition     = contains([local.peer_provider_account_id], var.vpc_peering_deluxe.peer.vpc.account_id)
    error_message = "The peer VPC account ID must match the aws.peer provider alias account VPC Peering Deluxe."
  }
}
