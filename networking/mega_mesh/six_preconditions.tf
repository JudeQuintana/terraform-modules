locals {
  # guarantee the centralized routers match their relative provider's region and account id before created peering attachments
  six_tgw_provider_region_check = {
    condition     = contains([local.six_provider_region_name], local.six_tgw.region)
    error_message = "Centralized Router Six's region must match the aws.six provider alias region for Mega Mesh."
  }

  six_tgw_provider_account_id_check = {
    condition     = contains([local.six_provider_account_id], local.six_tgw.account_id)
    error_message = "Centralized Router Six's account ID must match the aws.six provider alias account ID for Mega Mesh."
  }
}
