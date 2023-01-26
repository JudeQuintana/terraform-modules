output "local" {
  value = {
    account_id = local.local_account_id
    region     = local.local_region_name
    rules      = [for this in local.local_vpc_id_to_peer_intra_vpc_security_group_rules : this]
  }
}

output "peer" {
  value = {
    account_id = local.peer_account_id
    region     = local.peer_region_name
    rules      = [for this in local.peer_vpc_id_to_local_intra_vpc_security_group_rules : this]
  }
}

