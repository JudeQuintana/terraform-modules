locals {
  one_tgw_provider_region_check = {
    condition     = contains([local.one_provider_region_name], local.one_tgw.region)
    error_message = "Centralized Router One's region must match the aws.one provider alias region for Full Mesh Trio."
  }

  one_tgw_provider_account_id_check = {
    condition     = contains([local.one_provider_account_id], local.one_tgw.account_id)
    error_message = "Centralized Router One's account ID must match the aws.one provider alias account ID for Full Mesh Trio."
  }
}
