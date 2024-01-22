locals {
  # guarantee the centralized routers match their relative provider's region and account id before created peering attachments
  four_tgw_provider_region_check = {
    condition     = contains([local.four_provider_region_name], local.four_tgw.region)
    error_message = "Centralized Router Four's region must match the aws.four provider alias region for Mega Mesh."
  }

  four_tgw_provider_account_id_check = {
    condition     = contains([local.four_provider_account_id], local.four_tgw.account_id)
    error_message = "Centralized Router Four's account ID must match the aws.four provider alias account ID for Mega Mesh."
  }
}

