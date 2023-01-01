locals {
  # check for ASN and VPC network duplicates across regions with precondition
  # preconditions are evaluated on apply only but is the only way to evaluate
  # duplicate ASNs and VPC networks across regions (separate variables).
  all_vpc_networks = concat(local.local_tgws_all_vpc_networks, local.peer_tgws_all_vpc_networks)

  cross_region_vpc_networks_check = {
    condition     = length(distinct(local.all_vpc_networks)) == length(local.all_vpc_networks)
    error_message = "All Amazon side ASNs must be unique across providers/regions."
  }

  all_amazon_side_asns = concat(local.local_tgws[*].amazon_side_asn, local.peer_tgws[*].amazon_side_asn)

  cross_region_asn_check = {
    condition     = length(distinct(local.all_amazon_side_asns)) == length(local.all_amazon_side_asns)
    error_message = "All Amazon side ASNs must be unique across providers/regions."
  }

  # guarantee the centralized routers match their relative provider's region.
  local_provider_to_local_tgws_region_check = {
    condition     = contains(local.local_tgws[*].region, local.local_region_name)
    error_message = "All local Centralized Router regions must match the aws.local provider alias region."
  }

  peer_provider_to_peer_tgws_region_check = {
    condition     = contains(local.peer_tgws[*].region, local.peer_region_name)
    error_message = "All peer Centralized Router regions must match the aws.peer provider alias region."
  }
}
