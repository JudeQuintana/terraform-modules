locals {
  # guarantee the centralized routers match their relative provider's region and account id before created peering attachments
  one_tgw_provider_region_check = {
    condition     = contains([local.one_provider_region_name], local.one_tgw.region)
    error_message = "Centralized Router One's region must match the aws.one provider alias region for Full Mesh Trio."
  }

  two_tgw_provider_region_check = {
    condition     = contains([local.two_provider_region_name], local.two_tgw.region)
    error_message = "Centralized Router Two's region must match the aws.two provider alias region for Full Mesh Trio."
  }

  three_tgw_provider_region_check = {
    condition     = contains([local.three_provider_region_name], local.three_tgw.region)
    error_message = "Centralized Router Three's region must match the aws.three provider alias region for Full Mesh Trio."
  }

  one_tgw_provider_account_id_check = {
    condition     = contains([local.one_provider_account_id], local.one_tgw.account_id)
    error_message = "Centralized Router One's account ID must match the aws.one provider alias account ID Full Mesh Trio."
  }

  two_tgw_provider_account_id_check = {
    condition     = contains([local.two_provider_account_id], local.two_tgw.account_id)
    error_message = "Centralized Router Two's account ID must match the aws.two provider alias account ID Full Mesh Trio."
  }

  three_tgw_provider_account_id_check = {
    condition     = contains([local.three_provider_account_id], local.three_tgw.account_id)
    error_message = "Centralized Router Three's account ID must match the aws.three provider alias account ID Full Mesh Trio."
  }
}
