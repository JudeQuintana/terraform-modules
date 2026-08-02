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
    routing_policy = {
      deny = [
        {
          from = { network_cidr = "10.0.0.0/20" }
          to   = { network_cidr = "172.16.0.0/20" }
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
    routing_policy = {
      deny = [
        {
          from = {
            network_cidr    = "10.0.0.0/20"
            secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"]
          }
          to = {
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
    routing_policy = {
      deny = [
        {
          from = { network_cidr = "10.0.0.0/20" }
          to   = { network_cidr = "172.16.0.0/20" }
        },
        {
          from = { network_cidr = "10.0.0.0/20" }
          to   = { network_cidr = "192.168.0.0/20" }
        },
        {
          from = { network_cidr = "172.16.0.0/20" }
          to   = { network_cidr = "192.168.0.0/20" }
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
    routing_policy = {
      deny = [
        {
          from = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to   = { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
        },
        {
          from = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to   = { network_cidr = "192.168.0.0/20" }
        },
        {
          from = { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
          to   = { network_cidr = "192.168.0.0/20" }
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
    routing_policy = { deny = [] }
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

# === IPv6 ===

# ipv6 deny: app <-> cicd denied, general unaffected
run "ipv6_deny_app_to_cicd" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
    routing_policy = {
      deny = [
        {
          from = { network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56" }
          to   = { network_cidr = "172.16.0.0/20", ipv6_network_cidr = "2600:1f24:66:c200::/56" }
        }
      ]
    }
  }

  assert {
    condition = !anytrue([
      for route in output.ipv6 :
      contains(["rtb-0c92ed73f355dcc65", "rtb-04c6baa3a6a0af91e", "rtb-06836f9bc939ebbce"], route.route_table_id)
      && route.destination_ipv6_cidr_block == "2600:1f24:66:c200::/56"
    ])
    error_message = "App route tables should not have routes to cicd IPv6."
  }

  assert {
    condition = !anytrue([
      for route in output.ipv6 :
      contains(["rtb-01e2b1283c7404903", "rtb-0094331bdafb627f3"], route.route_table_id)
      && route.destination_ipv6_cidr_block == "2600:1f24:66:c100::/56"
    ])
    error_message = "Cicd route tables should not have routes to app IPv6."
  }

  assert {
    condition = alltrue([
      for route in output.ipv6 :
      !(contains(["rtb-066adc27add9a630e", "rtb-0989090af3edb78b1"], route.route_table_id))
      || contains(["2600:1f24:66:c100::/56", "2600:1f24:66:c200::/56"], route.destination_ipv6_cidr_block)
    ])
    error_message = "General route tables should still have routes to both app and cicd IPv6."
  }
}

# ipv6 deny with secondary cidrs
run "ipv6_with_secondary_cidrs_deny_app_to_cicd" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs_with_secondary_cidrs
    routing_policy = {
      deny = [
        {
          from = {
            network_cidr         = "10.0.0.0/20"
            ipv6_network_cidr    = "2600:1f24:66:c100::/56"
            ipv6_secondary_cidrs = ["2600:1f24:66:c800::/56"]
          }
          to = {
            network_cidr         = "172.16.0.0/20"
            ipv6_network_cidr    = "2600:1f24:66:c200::/56"
            ipv6_secondary_cidrs = ["2600:1f24:66:c600::/56"]
          }
        }
      ]
    }
  }

  assert {
    condition = !anytrue([
      for route in output.ipv6 :
      contains(["rtb-0c92ed73f355dcc65", "rtb-04c6baa3a6a0af91e", "rtb-06836f9bc939ebbce"], route.route_table_id)
      && contains(["2600:1f24:66:c200::/56", "2600:1f24:66:c600::/56"], route.destination_ipv6_cidr_block)
    ])
    error_message = "App route tables should not have routes to cicd IPv6 or cicd IPv6 secondaries."
  }

  assert {
    condition = !anytrue([
      for route in output.ipv6 :
      contains(["rtb-01e2b1283c7404903", "rtb-0094331bdafb627f3"], route.route_table_id)
      && contains(["2600:1f24:66:c100::/56", "2600:1f24:66:c800::/56"], route.destination_ipv6_cidr_block)
    ])
    error_message = "Cicd route tables should not have routes to app IPv6 or app IPv6 secondaries."
  }
}

# ipv6 deny all pairs = no routes
run "ipv6_deny_all_pairs" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
    routing_policy = {
      deny = [
        {
          from = { network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56" }
          to   = { network_cidr = "172.16.0.0/20", ipv6_network_cidr = "2600:1f24:66:c200::/56" }
        },
        {
          from = { network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56" }
          to   = { network_cidr = "192.168.0.0/20", ipv6_network_cidr = "2600:1f24:66:c300::/56" }
        },
        {
          from = { network_cidr = "172.16.0.0/20", ipv6_network_cidr = "2600:1f24:66:c200::/56" }
          to   = { network_cidr = "192.168.0.0/20", ipv6_network_cidr = "2600:1f24:66:c300::/56" }
        }
      ]
    }
  }

  assert {
    condition     = output.ipv6 == toset([])
    error_message = "Deny all IPv6 pairs should produce empty route set."
  }
}

# ipv6 empty deny = no change
run "ipv6_empty_deny_unchanged" {
  variables {
    vpcs   = run.setup.ipv6_tiered_vpcs
    routing_policy = { deny = [] }
  }

  assert {
    condition     = output.ipv6 == run.final.ipv6_set_of_route_objects_to_other_vpcs
    error_message = "Empty deny list should produce unchanged IPv6 routes."
  }
}

# ipv6 default policy = no change
run "ipv6_default_policy_unchanged" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
  }

  assert {
    condition     = output.ipv6 == run.final.ipv6_set_of_route_objects_to_other_vpcs
    error_message = "Default policy should produce unchanged IPv6 routes."
  }
}
