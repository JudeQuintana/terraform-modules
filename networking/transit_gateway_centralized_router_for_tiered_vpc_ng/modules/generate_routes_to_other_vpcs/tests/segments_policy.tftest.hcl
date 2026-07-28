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
    policy = {
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
    policy = {
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
    policy = {
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

# empty segments = no change (backwards compatibility)
run "ipv4_empty_segments_unchanged" {
  variables {
    vpcs   = run.setup.ipv4_tiered_vpcs
    policy = { segments = {} }
  }

  assert {
    condition     = output.ipv4 == run.final.ipv4_set_of_route_objects_to_other_vpcs
    error_message = "Empty segments should produce unchanged routes."
  }
}
