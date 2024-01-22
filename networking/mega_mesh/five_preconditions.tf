locals {
  # guarantee the centralized routers match their relative provider's region and account id before created peering attachments
  five_tgw_provider_region_check = {
    condition     = contains([local.five_provider_region_name], local.five_tgw.region)
    error_message = "Centralized Router Five's region must match the aws.five provider alias region for Mega Mesh."
  }

  five_tgw_provider_account_id_check = {
    condition     = contains([local.five_provider_account_id], local.five_tgw.account_id)
    error_message = "Centralized Router Five's account ID must match the aws.five provider alias account ID for Mega Mesh."
  }
}
