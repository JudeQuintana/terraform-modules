locals {
  # guarantee the centralized routers match their relative provider's region and account id before created peering attachments
  ten_tgw_provider_region_check = {
    condition     = contains([local.ten_provider_region_name], local.ten_tgw.region)
    error_message = "Centralized Router Ten's region must match the aws.ten provider alias region for Mega Mesh."
  }

  ten_tgw_provider_account_id_check = {
    condition     = contains([local.ten_provider_account_id], local.ten_tgw.account_id)
    error_message = "Centralized Router Ten's account ID must match the aws.ten provider alias account ID for Mega Mesh."
  }
}
