locals {
  two_tgw_provider_region_check = {
    condition     = contains([local.two_provider_region_name], local.two_tgw.region)
    error_message = "Centralized Router Two's region must match the aws.two provider alias region for Full Mesh Trio."
  }

  two_tgw_provider_account_id_check = {
    condition     = contains([local.two_provider_account_id], local.two_tgw.account_id)
    error_message = "Centralized Router Two's account ID must match the aws.two provider alias account ID for Full Mesh Trio."
  }
}
