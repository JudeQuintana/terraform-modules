run "setup" {
  module {
    source = "./tests/setup"
  }
}

# no assertions -> null output
run "no_assertions_empty" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
    }
  }

  assert {
    condition     = output.assertions == null
    error_message = "No assertions should produce null output."
  }
}

# all assertions pass: must_permit on permitted pair, must_deny on denied pair
run "all_assertions_pass" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
        allow = [
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "172.16.0.0/20" }
          }
        ]
      }
      assertions = {
        must_permit = [
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "172.16.0.0/20" }
          }
        ]
        must_deny = [
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "192.168.0.0/20" }
          }
        ]
      }
    }
  }

  assert {
    condition     = output.assertions.passed == true
    error_message = "All assertions should pass."
  }

  assert {
    condition     = length(output.assertions.violations.must_permit) == 0
    error_message = "No must_permit violations expected."
  }

  assert {
    condition     = length(output.assertions.violations.must_deny) == 0
    error_message = "No must_deny violations expected."
  }
}

# must_permit violation: pair is denied but asserted as must_permit
run "must_permit_violation" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
      }
      assertions = {
        must_permit = [
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "172.16.0.0/20" }
          }
        ]
      }
    }
  }

  assert {
    condition     = output.assertions.passed == false
    error_message = "Assertion should fail when must_permit pair is denied."
  }

  assert {
    condition     = length(output.assertions.violations.must_permit) == 1
    error_message = "Should have 1 must_permit violation."
  }

  assert {
    condition     = output.assertions.violations.must_permit[0].pair == "app:cicd"
    error_message = "Violation should identify the app:cicd pair."
  }

  assert {
    condition     = output.assertions.violations.must_permit[0].verdict == "denied:default"
    error_message = "Violation should show the actual verdict."
  }
}

# must_deny violation: pair is permitted but asserted as must_deny
run "must_deny_violation" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
      assertions = {
        must_deny = [
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "172.16.0.0/20" }
          }
        ]
      }
    }
  }

  assert {
    condition     = output.assertions.passed == false
    error_message = "Assertion should fail when must_deny pair is permitted."
  }

  assert {
    condition     = length(output.assertions.violations.must_deny) == 1
    error_message = "Should have 1 must_deny violation."
  }

  assert {
    condition     = output.assertions.violations.must_deny[0].pair == "app:cicd"
    error_message = "Violation should identify the app:cicd pair."
  }

  assert {
    condition     = output.assertions.violations.must_deny[0].verdict == "permitted:default"
    error_message = "Violation should show the actual verdict."
  }
}

# multiple violations: mixed must_permit and must_deny failures
run "multiple_violations" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
      }
      assertions = {
        must_permit = [
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "172.16.0.0/20" }
          },
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "192.168.0.0/20" }
          }
        ]
        must_deny = [
          {
            from = { network_cidr = "172.16.0.0/20" }
            to   = { network_cidr = "192.168.0.0/20" }
          }
        ]
      }
    }
  }

  assert {
    condition     = output.assertions.passed == false
    error_message = "Should fail with multiple violations."
  }

  assert {
    condition     = length(output.assertions.violations.must_permit) == 2
    error_message = "Should have 2 must_permit violations under default deny."
  }

  assert {
    condition     = length(output.assertions.violations.must_deny) == 0
    error_message = "must_deny on already-denied pair should not violate."
  }
}

# assertions with segments: must_deny on cross-segment pair, must_permit on same-segment pair
run "assertions_with_segments" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
        segments = {
          workers = [
            { network_cidr = "10.0.0.0/20" }
          ]
          infra = [
            { network_cidr = "172.16.0.0/20" }
          ]
        }
      }
      assertions = {
        must_deny = [
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "172.16.0.0/20" }
          }
        ]
        must_permit = [
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "192.168.0.0/20" }
          }
        ]
      }
    }
  }

  assert {
    condition     = output.assertions.passed == true
    error_message = "Cross-segment must_deny and unsegmented must_permit should both pass."
  }
}

# assertions with deny rule: must_deny satisfied by explicit deny
run "assertions_with_deny_rule" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
        deny = [
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "172.16.0.0/20" }
          }
        ]
      }
      assertions = {
        must_deny = [
          {
            from = { network_cidr = "10.0.0.0/20" }
            to   = { network_cidr = "172.16.0.0/20" }
          }
        ]
        must_permit = [
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
  }

  assert {
    condition     = output.assertions.passed == true
    error_message = "Explicit deny should satisfy must_deny, remaining pairs should satisfy must_permit."
  }
}

# empty assertions -> passed with no violations
run "empty_assertions_pass" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
      }
      assertions = {}
    }
  }

  assert {
    condition     = output.assertions.passed == true
    error_message = "Empty assertions should pass."
  }

  assert {
    condition     = length(output.assertions.violations.must_permit) == 0
    error_message = "Empty assertions should have no must_permit violations."
  }

  assert {
    condition     = length(output.assertions.violations.must_deny) == 0
    error_message = "Empty assertions should have no must_deny violations."
  }
}
