run "setup" {
  module {
    source = "./tests/setup"
  }
}

# zero connectivity: default=deny, no rules, all VPCs isolated
run "zero_connectivity_warning" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
      }
    }
  }

  assert {
    condition     = contains(output.diagnostics, "VPC \"app\" has zero connectivity. It is unsegmented under default=\"deny\" with no allow rules.")
    error_message = "Should warn about app having zero connectivity."
  }

  assert {
    condition     = length(output.diagnostics) == 3
    error_message = "Should have 3 zero-connectivity warnings (app, cicd, general)."
  }
}

# single-member segment warning
run "single_member_segment_warning" {
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
          isolated = [
            { network_cidr = "192.168.0.0/20" }
          ]
        }
      }
    }
  }

  assert {
    condition     = contains(output.diagnostics, "Segment \"isolated\" contains only 1 VPC. Single-member segments have no routing effect under default=\"deny\".")
    error_message = "Should warn about single-member segment."
  }
}

# redundant deny rule warning
run "redundant_deny_warning" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
        deny = [
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "172.16.0.0/20" }
          }
        ]
      }
    }
  }

  assert {
    condition     = contains(output.diagnostics, "Deny rule { app -> cicd } is redundant: this pair would already be denied without it.")
    error_message = "Should warn about redundant deny rule under default=deny."
  }
}

# out-of-scope CIDR in allow rule
run "out_of_scope_allow_cidr" {
  command = plan

  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
        allow = [
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "10.99.0.0/20" }
          }
        ]
      }
    }
  }

  expect_failures = [
    var.generate_routes_to_other_vpcs,
  ]
}

# out-of-scope CIDR in deny rule
run "out_of_scope_deny_cidr" {
  command = plan

  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
        deny = [
          {
            from = { network_cidr = "10.99.0.0/20" }
            to   = { network_cidr = "172.16.0.0/20" }
          }
        ]
      }
    }
  }

  expect_failures = [
    var.generate_routes_to_other_vpcs,
  ]
}

# out-of-scope CIDR in segment
run "out_of_scope_segment_cidr" {
  command = plan

  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
        segments = {
          workers = [
            { network_cidr = "10.0.0.0/20" },
            { network_cidr = "10.99.0.0/20" }
          ]
        }
      }
    }
  }

  expect_failures = [
    var.generate_routes_to_other_vpcs,
  ]
}

# redundant allow rule warning
run "redundant_allow_warning" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
        allow = [
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "172.16.0.0/20" }
          }
        ]
      }
    }
  }

  assert {
    condition     = contains(output.diagnostics, "Allow rule { app -> cicd } is redundant: this pair would already be permitted without it.")
    error_message = "Should warn about redundant allow rule under default=allow."
  }
}

# redundant allow is NOT redundant when it overrides cross-segment deny
run "allow_overrides_cross_segment_no_warning" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
        segments = {
          workers = [{ network_cidr = "10.0.0.0/20" }]
          infra   = [{ network_cidr = "172.16.0.0/20" }]
        }
        allow = [
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "172.16.0.0/20" }
          }
        ]
      }
    }
  }

  assert {
    condition     = !contains(output.diagnostics, "Allow rule { app -> cicd } is redundant")
    error_message = "Allow that overrides cross-segment deny should NOT be flagged as redundant."
  }
}

# single segment under default=allow has no effect
run "single_segment_default_allow_no_effect" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
        segments = {
          workers = [
            { network_cidr = "10.0.0.0/20" },
            { network_cidr = "172.16.0.0/20" }
          ]
        }
      }
    }
  }

  assert {
    condition     = contains(output.diagnostics, "Policy has 1 segment under default=\"allow\". A single segment has no routing effect when there is no other segment to deny against.")
    error_message = "Should warn about single segment under default=allow having no effect."
  }
}

# single segment under default=deny should NOT trigger this warning
run "single_segment_default_deny_no_warning" {
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
    }
  }

  assert {
    condition     = !contains(output.diagnostics, "A single segment has no routing effect")
    error_message = "Single segment under default=deny should NOT trigger the no-effect warning."
  }
}

# no warnings: clean policy
run "no_warnings_full_mesh" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
    }
  }

  assert {
    condition     = length(output.diagnostics) == 0
    error_message = "Full mesh should produce no diagnostics."
  }
}

# no warnings: well-formed deny policy with segments
run "no_warnings_valid_segments" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
        segments = {
          workers = [
            { network_cidr = "10.0.0.0/20" },
            { network_cidr = "172.16.0.0/20" },
            { network_cidr = "192.168.0.0/20" }
          ]
        }
      }
    }
  }

  assert {
    condition     = length(output.diagnostics) == 0
    error_message = "Well-formed policy with all VPCs segmented should produce no diagnostics."
  }
}
