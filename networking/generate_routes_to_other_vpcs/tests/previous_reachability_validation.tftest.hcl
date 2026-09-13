run "setup" {
  module {
    source = "./tests/setup"
  }
}

# wrong schema version = validation error
run "invalid_schema_version" {
  command = plan

  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
      previous_reachability = {
        schema_version = 99
        entries = [
          { from = "app", to = "cicd", verdict = "permitted", reason = "default" },
        ]
      }
    }
  }

  expect_failures = [
    var.generate_routes_to_other_vpcs
  ]
}

# invalid verdict = validation error
run "invalid_verdict" {
  command = plan

  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
      previous_reachability = {
        schema_version = 1
        entries = [
          { from = "app", to = "cicd", verdict = "allowed", reason = "default" },
        ]
      }
    }
  }

  expect_failures = [
    var.generate_routes_to_other_vpcs
  ]
}

# invalid reason = validation error
run "invalid_reason" {
  command = plan

  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
      previous_reachability = {
        schema_version = 1
        entries = [
          { from = "app", to = "cicd", verdict = "permitted", reason = "full-mesh" },
        ]
      }
    }
  }

  expect_failures = [
    var.generate_routes_to_other_vpcs
  ]
}

# valid previous reachability passes all validations
run "valid_previous_reachability" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
      previous_reachability = {
        schema_version = 1
        entries = [
          { from = "app", to = "cicd", verdict = "permitted", reason = "default" },
          { from = "app", to = "general", verdict = "denied", reason = "deny" },
          { from = "cicd", to = "general", verdict = "permitted", reason = "allow" },
        ]
      }
    }
  }

  assert {
    condition     = length(output.policy_diff) > 0
    error_message = "Valid previous reachability should produce a policy diff."
  }
}

# null previous reachability passes all validations
run "null_previous_reachability" {
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
