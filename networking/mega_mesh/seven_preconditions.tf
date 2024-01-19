locals {
  # guarantee the centralized routers match their relative provider's region and account id before created peering attachments
  seven_tgw_provider_region_check = {
    condition     = contains([local.seven_provider_region_name], local.seven_tgw.region)
    error_message = "Centralized Router Seven's region must match the aws.seven provider alias region for Mega Mesh."
  }

  seven_tgw_provider_account_id_check = {
    condition     = contains([local.seven_provider_account_id], local.seven_tgw.account_id)
    error_message = "Centralized Router Seven's account ID must match the aws.seven provider alias account ID for Mega Mesh."
  }
}
