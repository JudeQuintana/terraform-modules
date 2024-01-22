locals {
  # guarantee the centralized routers match their relative provider's region and account id before created peering attachments
  nine_tgw_provider_region_check = {
    condition     = contains([local.nine_provider_region_name], local.nine_tgw.region)
    error_message = "Centralized Router Nine's region must match the aws.nine provider alias region for Mega Mesh."
  }

  nine_tgw_provider_account_id_check = {
    condition     = contains([local.nine_provider_account_id], local.nine_tgw.account_id)
    error_message = "Centralized Router Nine's account ID must match the aws.nine provider alias account ID for Mega Mesh."
  }
}
