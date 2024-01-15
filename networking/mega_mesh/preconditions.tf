locals {
  # guarantee the centralized routers match their relative provider's region and account id before created peering attachments
  one_tgw_provider_region_check = {
    condition     = contains([local.one_provider_region_name], local.one_tgw.region)
    error_message = "Centralized Router One's region must match the aws.one provider alias region for Mega Mesh."
  }

  one_tgw_provider_account_id_check = {
    condition     = contains([local.one_provider_account_id], local.one_tgw.account_id)
    error_message = "Centralized Router One's account ID must match the aws.one provider alias account ID Mega Mesh."
  }

  two_tgw_provider_region_check = {
    condition     = contains([local.two_provider_region_name], local.two_tgw.region)
    error_message = "Centralized Router Two's region must match the aws.two provider alias region for Mega Mesh."
  }

  two_tgw_provider_account_id_check = {
    condition     = contains([local.two_provider_account_id], local.two_tgw.account_id)
    error_message = "Centralized Router Two's account ID must match the aws.two provider alias account ID Mega Mesh."
  }

  three_tgw_provider_region_check = {
    condition     = contains([local.three_provider_region_name], local.three_tgw.region)
    error_message = "Centralized Router Three's region must match the aws.three provider alias region for Mega Mesh."
  }

  three_tgw_provider_account_id_check = {
    condition     = contains([local.three_provider_account_id], local.three_tgw.account_id)
    error_message = "Centralized Router Three's account ID must match the aws.three provider alias account ID Mega Mesh."
  }

  four_tgw_provider_region_check = {
    condition     = contains([local.four_provider_region_name], local.four_tgw.region)
    error_message = "Centralized Router Four's region must match the aws.four provider alias region for Mega Mesh."
  }

  four_tgw_provider_account_id_check = {
    condition     = contains([local.four_provider_account_id], local.four_tgw.account_id)
    error_message = "Centralized Router Four's account ID must match the aws.four provider alias account ID Mega Mesh."
  }

  five_tgw_provider_region_check = {
    condition     = contains([local.five_provider_region_name], local.five_tgw.region)
    error_message = "Centralized Router Five's region must match the aws.five provider alias region for Mega Mesh."
  }

  five_tgw_provider_account_id_check = {
    condition     = contains([local.five_provider_account_id], local.five_tgw.account_id)
    error_message = "Centralized Router Five's account ID must match the aws.five provider alias account ID Mega Mesh."
  }
}
