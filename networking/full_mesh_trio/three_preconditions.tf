locals {
  three_tgw_provider_region_check = {
    condition     = contains([local.three_provider_region_name], local.three_tgw.region)
    error_message = "Centralized Router Three's region must match the aws.three provider alias region for Full Mesh Trio."
  }

  three_tgw_provider_account_id_check = {
    condition     = contains([local.three_provider_account_id], local.three_tgw.account_id)
    error_message = "Centralized Router Three's account ID must match the aws.three provider alias account ID for Full Mesh Trio."
  }
}
