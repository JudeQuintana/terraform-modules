run "setup" {
  module {
    source = "./tests/setup"
  }
}

# no equivalent policy -> empty output
run "no_equivalent_empty" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      default = "allow"
    }
  }

  assert {
    condition     = output.equivalence == null
    error_message = "No equivalent policy should produce null output."
  }
}

# same policy is equivalent to itself
run "identical_policies_are_equivalent" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      default = "allow"
      deny = [{
        from = { network_cidr = "10.0.0.0/20" }
        to   = { network_cidr = "172.16.0.0/20" }
      }]
    }
    equivalent_routing_policy = {
      default = "allow"
      deny = [{
        from = { network_cidr = "10.0.0.0/20" }
        to   = { network_cidr = "172.16.0.0/20" }
      }]
    }
  }

  assert {
    condition     = output.equivalence.equivalent == true
    error_message = "Identical policies must be equivalent."
  }

  assert {
    condition     = length(output.equivalence.mismatches) == 0
    error_message = "Identical policies should have no mismatches."
  }
}

# allow-with-deny == deny-with-allows (classic migration proof)
# deny/allow rules are bidirectional, so deny {app->cicd} blocks both directions
run "allow_with_deny_equals_deny_with_allows" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    # policy A: allow everything except app <-> cicd (bidirectional deny)
    routing_policy = {
      default = "allow"
      deny = [{
        from = { network_cidr = "10.0.0.0/20" }
        to   = { network_cidr = "172.16.0.0/20" }
      }]
    }
    # policy B: deny everything, explicitly allow the pairs that were permitted
    # rules are bidirectional so only need app<->general and cicd<->general
    equivalent_routing_policy = {
      default = "deny"
      allow = [
        { from = { network_cidr = "10.0.0.0/20" }, to = { network_cidr = "192.168.0.0/20" } },
        { from = { network_cidr = "172.16.0.0/20" }, to = { network_cidr = "192.168.0.0/20" } },
      ]
    }
  }

  assert {
    condition     = output.equivalence.equivalent == true
    error_message = "Allow-with-deny should be equivalent to deny-with-explicit-allows for the same connectivity."
  }
}

# segments == explicit allows (proves segment is sugar for allow pairs)
run "segment_equals_explicit_allows" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    # policy A: deny default, segment [app, cicd]
    routing_policy = {
      default = "deny"
      segments = {
        workers = [
          { network_cidr = "10.0.0.0/20" },
          { network_cidr = "172.16.0.0/20" }
        ]
      }
    }
    # policy B: deny default, explicit allow app <-> cicd
    equivalent_routing_policy = {
      default = "deny"
      allow = [
        { from = { network_cidr = "10.0.0.0/20" }, to = { network_cidr = "172.16.0.0/20" } },
      ]
    }
  }

  assert {
    condition     = output.equivalence.equivalent == true
    error_message = "Segment membership should be equivalent to explicit bidirectional allows."
  }
}

# non-equivalent policies show mismatches
run "non_equivalent_shows_mismatches" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      default = "allow"
    }
    equivalent_routing_policy = {
      default = "deny"
    }
  }

  assert {
    condition     = output.equivalence.equivalent == false
    error_message = "Full mesh vs zero trust must not be equivalent."
  }

  assert {
    condition     = length(output.equivalence.mismatches) == 3
    error_message = "All 3 deduplicated pairs should be mismatched."
  }
}

# partial mismatch: one deny difference
run "partial_mismatch" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      default = "allow"
    }
    equivalent_routing_policy = {
      default = "allow"
      deny = [{
        from = { network_cidr = "10.0.0.0/20" }
        to   = { network_cidr = "172.16.0.0/20" }
      }]
    }
  }

  assert {
    condition     = output.equivalence.equivalent == false
    error_message = "Adding a deny rule breaks equivalence."
  }

  assert {
    condition     = length(output.equivalence.mismatches) == 1
    error_message = "Bidirectional deny should produce 1 deduplicated mismatch."
  }

  assert {
    condition     = output.equivalence.mismatches["app:cicd"].routing_policy == "permitted:default"
    error_message = "Original should show permitted:default for app:cicd."
  }

  assert {
    condition     = output.equivalence.mismatches["app:cicd"].equivalent_routing_policy == "denied:deny"
    error_message = "Equivalent should show denied:deny for app:cicd."
  }
}
