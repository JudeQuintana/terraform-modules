run "setup" {
  module {
    source = "./tests/setup"
  }
}

# no previous reachability -> empty diff
run "no_previous_empty_diff" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
    }
  }

  assert {
    condition     = length(output.policy_diff) == 0
    error_message = "No previous reachability should produce empty diff."
  }
}

# full mesh -> deny all = all pairs removed
run "full_mesh_to_deny_all" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
      }
      previous_reachability = {
        "app:cicd"      = "permitted:default"
        "app:general"   = "permitted:default"
        "cicd:app"      = "permitted:default"
        "cicd:general"  = "permitted:default"
        "general:app"   = "permitted:default"
        "general:cicd"  = "permitted:default"
      }
    }
  }

  assert {
    condition     = length(output.policy_diff.removed) == 3
    error_message = "All 3 deduplicated pairs should be removed."
  }

  assert {
    condition     = length(output.policy_diff.added) == 0
    error_message = "No pairs should be added."
  }
}

# deny all -> full mesh = all pairs added
run "deny_all_to_full_mesh" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
      previous_reachability = {
        "app:cicd"      = "denied:default"
        "app:general"   = "denied:default"
        "cicd:app"      = "denied:default"
        "cicd:general"  = "denied:default"
        "general:app"   = "denied:default"
        "general:cicd"  = "denied:default"
      }
    }
  }

  assert {
    condition     = length(output.policy_diff.added) == 3
    error_message = "All 3 deduplicated pairs should be added."
  }

  assert {
    condition     = length(output.policy_diff.removed) == 0
    error_message = "No pairs should be removed."
  }
}

# add a segment: full mesh -> segment [app, cicd] under deny
run "add_segment_selective" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
        segments = {
          workers = [
            { network_cidr = "10.0.0.0/20" },
            { network_cidr = "172.16.0.0/20" }
          ]
        }
      }
      previous_reachability = {
        "app:cicd"      = "denied:default"
        "app:general"   = "denied:default"
        "cicd:app"      = "denied:default"
        "cicd:general"  = "denied:default"
        "general:app"   = "denied:default"
        "general:cicd"  = "denied:default"
      }
    }
  }

  assert {
    condition     = toset(output.policy_diff.added) == toset(["app:cicd"])
    error_message = "Only app:cicd (deduplicated) should be added."
  }

  assert {
    condition     = length(output.policy_diff.removed) == 0
    error_message = "No pairs should be removed."
  }
}

# unchanged: same policy, same result
run "no_change" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
      previous_reachability = {
        "app:cicd"      = "permitted:default"
        "app:general"   = "permitted:default"
        "cicd:app"      = "permitted:default"
        "cicd:general"  = "permitted:default"
        "general:app"   = "permitted:default"
        "general:cicd"  = "permitted:default"
      }
    }
  }

  assert {
    condition     = length(output.policy_diff.added) == 0
    error_message = "No pairs should be added."
  }

  assert {
    condition     = length(output.policy_diff.removed) == 0
    error_message = "No pairs should be removed."
  }

  assert {
    condition     = length(output.policy_diff.unchanged) == 3
    error_message = "All 3 deduplicated pairs should be unchanged."
  }
}
