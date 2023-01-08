locals {
  # check for ASN and VPC network duplicates across regions with precondition.
  # preconditions are evaluated on apply only.
  # detecting duplicate ASNs and VPC networks across regions can be done in
  # var.super_router validations but it would involve having to duplicate condition code.
  # kind of making a mess so it's easier to use them as a precondition instead.
  all_vpc_networks = concat(local.local_tgws_all_vpc_networks, local.peer_tgws_all_vpc_networks)

  cross_region_vpc_networks_check = {
    condition     = length(distinct(local.all_vpc_networks)) == length(local.all_vpc_networks)
    error_message = "All VPC networks must be unique across regions."
  }

  all_amazon_side_asns = concat(local.local_tgws[*].amazon_side_asn, local.peer_tgws[*].amazon_side_asn)

  cross_region_asn_check = {
    condition     = length(distinct(local.all_amazon_side_asns)) == length(local.all_amazon_side_asns)
    error_message = "All amazon side ASNs must be unique across regions."
  }

  # guarantee the centralized routers match their relative provider's region.
  local_provider_to_local_tgws_region_check = {
    condition     = alltrue([for region in local.local_tgws[*].region : contains([local.local_region_name], region)])
    error_message = "All local centralized router regions must match the aws.local provider alias region."
  }

  peer_provider_to_peer_tgws_region_check = {
    condition     = alltrue([for region in local.peer_tgws[*].region : contains([local.peer_region_name], region)])
    error_message = "All peer centralized router regions must match the aws.peer provider alias region."
  }
}
