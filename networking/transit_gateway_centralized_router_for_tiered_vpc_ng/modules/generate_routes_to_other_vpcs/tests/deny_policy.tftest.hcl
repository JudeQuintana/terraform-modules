run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "final_deny" {
  module {
    source = "./tests/final_deny"
  }
}

# ipv4 deny: app <-> cicd denied, general unaffected
run "ipv4_deny_app_to_cicd" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    policy = {
      deny = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20" }
          to_vpc   = { network_cidr = "172.16.0.0/20" }
        }
      ]
    }
  }

  assert {
    condition     = output.ipv4 == run.final_deny.ipv4_deny_app_to_cicd
    error_message = "Incorrect deny result for app <-> cicd:\n[\n${join("   \n", [for route in output.ipv4 : format("{\n  destination_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_cidr_block, route.route_table_id)])}\n]"
  }
}

# ipv4 deny with secondary cidrs: app (with secondaries) <-> cicd (with secondaries) denied
run "ipv4_with_secondary_cidrs_deny_app_to_cicd" {
  variables {
    vpcs = run.setup.ipv4_with_secondary_cidrs_tiered_vpcs
    policy = {
      deny = [
        {
          from_vpc = {
            network_cidr    = "10.0.0.0/20"
            secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"]
          }
          to_vpc = {
            network_cidr    = "172.16.0.0/20"
            secondary_cidrs = ["172.17.0.0/20"]
          }
        }
      ]
    }
  }

  assert {
    condition     = output.ipv4 == run.final_deny.ipv4_with_secondary_cidrs_deny_app_to_cicd
    error_message = "Incorrect deny result for app <-> cicd with secondary cidrs:\n[\n${join("   \n", [for route in output.ipv4 : format("{\n  destination_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_cidr_block, route.route_table_id)])}\n]"
  }
}

# deny all pairs = no routes
run "ipv4_deny_all_pairs" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    policy = {
      deny = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20" }
          to_vpc   = { network_cidr = "172.16.0.0/20" }
        },
        {
          from_vpc = { network_cidr = "10.0.0.0/20" }
          to_vpc   = { network_cidr = "192.168.0.0/20" }
        },
        {
          from_vpc = { network_cidr = "172.16.0.0/20" }
          to_vpc   = { network_cidr = "192.168.0.0/20" }
        }
      ]
    }
  }

  assert {
    condition     = output.ipv4 == run.final_deny.ipv4_deny_all_pairs
    error_message = "Deny all pairs should produce empty route set."
  }
}

# deny all pairs with secondary cidrs = no routes
run "ipv4_with_secondary_cidrs_deny_all_pairs" {
  variables {
    vpcs = run.setup.ipv4_with_secondary_cidrs_tiered_vpcs
    policy = {
      deny = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to_vpc   = { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
        },
        {
          from_vpc = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to_vpc   = { network_cidr = "192.168.0.0/20" }
        },
        {
          from_vpc = { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
          to_vpc   = { network_cidr = "192.168.0.0/20" }
        }
      ]
    }
  }

  assert {
    condition     = output.ipv4 == run.final_deny.ipv4_deny_all_pairs
    error_message = "Deny all pairs with secondary cidrs should produce empty route set."
  }
}

run "final" {
  module {
    source = "./tests/final"
  }
}

# empty deny = no change (backwards compatibility)
run "ipv4_empty_deny_unchanged" {
  variables {
    vpcs   = run.setup.ipv4_tiered_vpcs
    policy = { deny = [] }
  }

  assert {
    condition     = output.ipv4 == run.final.ipv4_set_of_route_objects_to_other_vpcs
    error_message = "Empty deny list should produce unchanged routes."
  }
}

# default policy (no policy arg) = no change (backwards compatibility)
run "ipv4_default_policy_unchanged" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
  }

  assert {
    condition     = output.ipv4 == run.final.ipv4_set_of_route_objects_to_other_vpcs
    error_message = "Default policy should produce unchanged routes."
  }
}
