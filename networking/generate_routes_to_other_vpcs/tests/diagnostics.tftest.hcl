run "setup" {
  module {
    source = "./tests/setup"
  }
}

# zero connectivity: default=deny, no rules, all VPCs isolated
run "zero_connectivity_warning" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      default = "deny"
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

  assert {
    condition     = contains(output.diagnostics, "Segment \"isolated\" contains only 1 VPC. Single-member segments have no routing effect under default=\"deny\".")
    error_message = "Should warn about single-member segment."
  }
}

# redundant deny rule warning
run "redundant_deny_warning" {
  variables {
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

  assert {
    condition     = contains(output.diagnostics, "Deny rule { app -> cicd } is redundant: this pair would already be denied without it.")
    error_message = "Should warn about redundant deny rule under default=deny."
  }
}

# out-of-scope CIDR in allow rule
run "out_of_scope_allow_cidr" {
  command = plan

  variables {
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

  expect_failures = [
    output.ipv4,
  ]
}

# out-of-scope CIDR in deny rule
run "out_of_scope_deny_cidr" {
  command = plan

  variables {
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

  expect_failures = [
    output.ipv4,
  ]
}

# no warnings: clean policy
run "no_warnings_full_mesh" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      default = "allow"
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

  assert {
    condition     = length(output.diagnostics) == 0
    error_message = "Well-formed policy with all VPCs segmented should produce no diagnostics."
  }
}
