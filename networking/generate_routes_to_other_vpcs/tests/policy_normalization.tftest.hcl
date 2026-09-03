run "setup" {
  module {
    source = "./tests/setup"
  }
}

# full mesh under default=allow is already minimal (0 rules)
run "full_mesh_already_minimal" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
    }
  }

  assert {
    condition     = output.policy_normalization.current_rule_count == 0
    error_message = "Current policy has 0 rules."
  }

  assert {
    condition     = output.policy_normalization.normalized_rule_count == 0
    error_message = "Normalized policy should have 0 rules."
  }

  assert {
    condition     = output.policy_normalization.normalized_policy.default == "allow"
    error_message = "Full mesh is best expressed as default=allow."
  }
}

# deny all under default=deny is already minimal (0 rules)
run "deny_all_already_minimal" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
      }
    }
  }

  assert {
    condition     = output.policy_normalization.current_rule_count == 0
    error_message = "Current policy has 0 rules."
  }

  assert {
    condition     = output.policy_normalization.normalized_rule_count == 0
    error_message = "Normalized policy should have 0 rules."
  }

  assert {
    condition     = output.policy_normalization.normalized_policy.default == "deny"
    error_message = "Zero trust is best expressed as default=deny."
  }
}

# 3 explicit allow rules under deny = full mesh, normalizer suggests default=allow (0 rules)
run "explicit_allows_to_default_allow" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
        allow = [
          { from = { network_cidr = "10.0.0.0/20" }, to = { network_cidr = "172.16.0.0/20" } },
          { from = { network_cidr = "10.0.0.0/20" }, to = { network_cidr = "192.168.0.0/20" } },
          { from = { network_cidr = "172.16.0.0/20" }, to = { network_cidr = "192.168.0.0/20" } },
        ]
      }
    }
  }

  assert {
    condition     = output.policy_normalization.current_rule_count == 3
    error_message = "Current policy has 3 allow rules."
  }

  assert {
    condition     = output.policy_normalization.normalized_rule_count == 0
    error_message = "Full mesh needs 0 rules under default=allow."
  }

  assert {
    condition     = output.policy_normalization.normalized_policy.default == "allow"
    error_message = "Should suggest default=allow for full mesh."
  }
}

# 2 deny rules under allow -> 1 segment under deny
# app:cicd permitted, app:general denied, cicd:general denied
# normalizer detects {app, cicd} segment, suggests default=deny
run "deny_rules_to_segment" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
        deny = [
          { from = { network_cidr = "10.0.0.0/20" }, to = { network_cidr = "192.168.0.0/20" } },
          { from = { network_cidr = "172.16.0.0/20" }, to = { network_cidr = "192.168.0.0/20" } },
        ]
      }
    }
  }

  assert {
    condition     = output.policy_normalization.current_rule_count == 2
    error_message = "Current policy has 2 deny rules."
  }

  assert {
    condition     = output.policy_normalization.normalized_rule_count == 1
    error_message = "Normalized to 1 segment."
  }

  assert {
    condition     = output.policy_normalization.normalized_policy.default == "deny"
    error_message = "Should suggest default=deny with segment."
  }

  assert {
    condition     = length(output.policy_normalization.normalized_policy.segments) == 1
    error_message = "Should suggest 1 segment."
  }

  assert {
    condition     = toset(output.policy_normalization.normalized_policy.segments["group_0"]) == toset(["app", "cicd"])
    error_message = "Segment should contain app and cicd."
  }

  assert {
    condition     = length(output.policy_normalization.normalized_policy.allow) == 0
    error_message = "No allow rules needed."
  }

  assert {
    condition     = length(output.policy_normalization.normalized_policy.deny) == 0
    error_message = "No deny rules needed under default=deny."
  }
}

# 2 allow rules under deny -> 1 deny rule under allow is shorter
# app:cicd permitted, cicd:general permitted, app:general denied
run "suggest_fewer_rules" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
        allow = [
          { from = { network_cidr = "10.0.0.0/20" }, to = { network_cidr = "172.16.0.0/20" } },
          { from = { network_cidr = "172.16.0.0/20" }, to = { network_cidr = "192.168.0.0/20" } },
        ]
      }
    }
  }

  assert {
    condition     = output.policy_normalization.current_rule_count == 2
    error_message = "Current policy has 2 allow rules."
  }

  assert {
    condition     = output.policy_normalization.normalized_rule_count == 1
    error_message = "Normalized to 1 deny rule under default=allow."
  }

  assert {
    condition     = output.policy_normalization.normalized_policy.default == "allow"
    error_message = "Should suggest default=allow."
  }

  assert {
    condition     = length(output.policy_normalization.normalized_policy.deny) == 1
    error_message = "Should have 1 deny rule."
  }

  assert {
    condition     = output.policy_normalization.normalized_policy.deny[0].from == "app" || output.policy_normalization.normalized_policy.deny[0].to == "app"
    error_message = "Deny rule should involve app."
  }

  assert {
    condition     = output.policy_normalization.normalized_policy.deny[0].from == "general" || output.policy_normalization.normalized_policy.deny[0].to == "general"
    error_message = "Deny rule should involve general."
  }
}

# existing segment already optimal
run "existing_segment_optimal" {
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
    condition     = output.policy_normalization.current_rule_count == 1
    error_message = "Current policy has 1 segment."
  }

  assert {
    condition     = output.policy_normalization.normalized_rule_count == 1
    error_message = "Already optimal at 1 segment."
  }

  assert {
    condition     = output.policy_normalization.normalized_policy.default == "deny"
    error_message = "Should stay default=deny."
  }

  assert {
    condition     = length(output.policy_normalization.normalized_policy.segments) == 1
    error_message = "Should suggest 1 segment."
  }
}

# single VPC: trivially minimal
run "single_vpc" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_one_tiered_vpc
      routing_policy = {
        default = "allow"
      }
    }
  }

  assert {
    condition     = output.policy_normalization.current_rule_count == 0
    error_message = "No rules for single VPC."
  }

  assert {
    condition     = output.policy_normalization.normalized_rule_count == 0
    error_message = "Normalized to 0 rules."
  }
}
