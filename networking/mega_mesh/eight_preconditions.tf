locals {
  # guarantee the centralized routers match their relative provider's region and account id before created peering attachments
  eight_tgw_provider_region_check = {
    condition     = contains([local.eight_provider_region_name], local.eight_tgw.region)
    error_message = "Centralized Router Eight's region must match the aws.eight provider alias region for Mega Mesh."
  }

  eight_tgw_provider_account_id_check = {
    condition     = contains([local.eight_provider_account_id], local.eight_tgw.account_id)
    error_message = "Centralized Router Eight's account ID must match the aws.eight provider alias account ID for Mega Mesh."
  }
}
