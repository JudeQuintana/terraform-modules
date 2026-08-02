run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "final_segments" {
  module {
    source = "./tests/final_segments"
  }
}

run "final" {
  module {
    source = "./tests/final"
  }
}

# single segment with unsegmented VPC = unsegmented routes to everything, same segment routes to each other
# app and cicd in "workers" segment, general unsegmented
# all can reach all = full mesh (same as no policy)
run "ipv4_one_segment_general_unsegmented" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      segments = {
        workers = [
          { network_cidr = "10.0.0.0/20" },
          { network_cidr = "172.16.0.0/20" }
        ]
      }
    }
  }

  assert {
    condition     = output.ipv4 == run.final.ipv4_set_of_route_objects_to_other_vpcs
    error_message = "Single segment with unsegmented VPC should produce full mesh."
  }
}

# two segments: app in "alpha", cicd in "beta", general unsegmented
# cross-segment denied, unsegmented routes to all
run "ipv4_two_segments_general_unsegmented" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      segments = {
        alpha = [{ network_cidr = "10.0.0.0/20" }]
        beta  = [{ network_cidr = "172.16.0.0/20" }]
      }
    }
  }

  assert {
    condition     = output.ipv4 == run.final_segments.ipv4_two_segments_general_unsegmented
    error_message = "Two segments with unsegmented general should deny cross-segment only:\n[\n${join("   \n", [for route in output.ipv4 : format("{\n  destination_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_cidr_block, route.route_table_id)])}\n]"
  }
}

# all three in separate segments = total isolation (no routes)
run "ipv4_all_separate_segments" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      segments = {
        alpha = [{ network_cidr = "10.0.0.0/20" }]
        beta  = [{ network_cidr = "172.16.0.0/20" }]
        gamma = [{ network_cidr = "192.168.0.0/20" }]
      }
    }
  }

  assert {
    condition     = output.ipv4 == run.final_segments.ipv4_all_separate_segments
    error_message = "All VPCs in separate segments should produce empty route set."
  }
}

# segments with secondary cidrs: app in "alpha", cicd in "beta", general unsegmented
# cross-segment denied (including all secondary cidrs), unsegmented routes to all
run "ipv4_with_secondary_cidrs_two_segments_general_unsegmented" {
  variables {
    vpcs = run.setup.ipv4_with_secondary_cidrs_tiered_vpcs
    routing_policy = {
      segments = {
        alpha = [{ network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }]
        beta  = [{ network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }]
      }
    }
  }

  assert {
    condition     = output.ipv4 == run.final_segments.ipv4_with_secondary_cidrs_two_segments_general_unsegmented
    error_message = "Two segments with secondary cidrs should deny cross-segment only:\n[\n${join("   \n", [for route in output.ipv4 : format("{\n  destination_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_cidr_block, route.route_table_id)])}\n]"
  }
}

# segments with secondary cidrs: all separate segments = total isolation
run "ipv4_with_secondary_cidrs_all_separate_segments" {
  variables {
    vpcs = run.setup.ipv4_with_secondary_cidrs_tiered_vpcs
    routing_policy = {
      segments = {
        alpha = [{ network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }]
        beta  = [{ network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }]
        gamma = [{ network_cidr = "192.168.0.0/20" }]
      }
    }
  }

  assert {
    condition     = output.ipv4 == run.final_segments.ipv4_with_secondary_cidrs_all_separate_segments
    error_message = "All VPCs in separate segments with secondary cidrs should produce empty route set."
  }
}

# empty segments = no change (backwards compatibility)
run "ipv4_empty_segments_unchanged" {
  variables {
    vpcs   = run.setup.ipv4_tiered_vpcs
    routing_policy = { segments = {} }
  }

  assert {
    condition     = output.ipv4 == run.final.ipv4_set_of_route_objects_to_other_vpcs
    error_message = "Empty segments should produce unchanged routes."
  }
}

# vpc in multiple segments = validation error
run "ipv4_vpc_in_multiple_segments" {
  command = plan

  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      segments = {
        alpha = [{ network_cidr = "10.0.0.0/20" }]
        beta  = [{ network_cidr = "10.0.0.0/20" }, { network_cidr = "172.16.0.0/20" }]
      }
    }
  }

  expect_failures = [
    var.routing_policy
  ]
}

# === IPv6 ===

# two segments: app in "alpha", cicd in "beta", general unsegmented
# cross-segment denied for IPv6, unsegmented routes to all
run "ipv6_two_segments_general_unsegmented" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
    routing_policy = {
      segments = {
        alpha = [{ network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56" }]
        beta  = [{ network_cidr = "172.16.0.0/20", ipv6_network_cidr = "2600:1f24:66:c200::/56" }]
      }
    }
  }

  assert {
    condition = !anytrue([
      for route in output.ipv6 :
      contains(["rtb-0c92ed73f355dcc65", "rtb-04c6baa3a6a0af91e", "rtb-06836f9bc939ebbce"], route.route_table_id)
      && route.destination_ipv6_cidr_block == "2600:1f24:66:c200::/56"
    ])
    error_message = "App route tables should not have routes to cicd IPv6 (cross-segment)."
  }

  assert {
    condition = !anytrue([
      for route in output.ipv6 :
      contains(["rtb-01e2b1283c7404903", "rtb-0094331bdafb627f3"], route.route_table_id)
      && route.destination_ipv6_cidr_block == "2600:1f24:66:c100::/56"
    ])
    error_message = "Cicd route tables should not have routes to app IPv6 (cross-segment)."
  }

  assert {
    condition = anytrue([
      for route in output.ipv6 :
      route.route_table_id == "rtb-066adc27add9a630e"
      && route.destination_ipv6_cidr_block == "2600:1f24:66:c100::/56"
    ])
    error_message = "General (unsegmented) should still reach app IPv6."
  }

  assert {
    condition = anytrue([
      for route in output.ipv6 :
      route.route_table_id == "rtb-066adc27add9a630e"
      && route.destination_ipv6_cidr_block == "2600:1f24:66:c200::/56"
    ])
    error_message = "General (unsegmented) should still reach cicd IPv6."
  }
}

# all three in separate segments = total isolation (no IPv6 routes)
run "ipv6_all_separate_segments" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
    routing_policy = {
      segments = {
        alpha = [{ network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56" }]
        beta  = [{ network_cidr = "172.16.0.0/20", ipv6_network_cidr = "2600:1f24:66:c200::/56" }]
        gamma = [{ network_cidr = "192.168.0.0/20", ipv6_network_cidr = "2600:1f24:66:c300::/56" }]
      }
    }
  }

  assert {
    condition     = output.ipv6 == toset([])
    error_message = "All VPCs in separate segments should produce empty IPv6 route set."
  }
}

# segments with ipv6 secondary cidrs: app in "alpha", cicd in "beta", general unsegmented
run "ipv6_with_secondary_cidrs_two_segments_general_unsegmented" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs_with_secondary_cidrs
    routing_policy = {
      segments = {
        alpha = [{ network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56", ipv6_secondary_cidrs = ["2600:1f24:66:c800::/56"] }]
        beta  = [{ network_cidr = "172.16.0.0/20", ipv6_network_cidr = "2600:1f24:66:c200::/56", ipv6_secondary_cidrs = ["2600:1f24:66:c600::/56"] }]
      }
    }
  }

  assert {
    condition = !anytrue([
      for route in output.ipv6 :
      contains(["rtb-0c92ed73f355dcc65", "rtb-04c6baa3a6a0af91e", "rtb-06836f9bc939ebbce"], route.route_table_id)
      && contains(["2600:1f24:66:c200::/56", "2600:1f24:66:c600::/56"], route.destination_ipv6_cidr_block)
    ])
    error_message = "App route tables should not have routes to cicd IPv6 or secondaries (cross-segment)."
  }

  assert {
    condition = !anytrue([
      for route in output.ipv6 :
      contains(["rtb-01e2b1283c7404903", "rtb-0094331bdafb627f3"], route.route_table_id)
      && contains(["2600:1f24:66:c100::/56", "2600:1f24:66:c800::/56"], route.destination_ipv6_cidr_block)
    ])
    error_message = "Cicd route tables should not have routes to app IPv6 or secondaries (cross-segment)."
  }
}

# empty segments = no change for IPv6
run "ipv6_empty_segments_unchanged" {
  variables {
    vpcs   = run.setup.ipv6_tiered_vpcs
    routing_policy = { segments = {} }
  }

  assert {
    condition     = output.ipv6 == run.final.ipv6_set_of_route_objects_to_other_vpcs
    error_message = "Empty segments should produce unchanged IPv6 routes."
  }
}
