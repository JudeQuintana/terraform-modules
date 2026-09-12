run "setup" {
  module {
    source = "./tests/setup"
  }
}

# default=allow (full mesh) -> all pairs permitted via default
run "ipv4_full_mesh_reachability" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
    }
  }

  assert {
    condition = output.reachability == [
      { from = "app", to = "cicd", verdict = "permitted", reason = "default" },
      { from = "app", to = "general", verdict = "permitted", reason = "default" },
      { from = "cicd", to = "general", verdict = "permitted", reason = "default" },
    ]
    error_message = "Default allow should show all pairs permitted via default."
  }
}

# default=deny with no rules -> all pairs denied via default
run "ipv4_zero_trust_reachability" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
      }
    }
  }

  assert {
    condition = output.reachability == [
      { from = "app", to = "cicd", verdict = "denied", reason = "default" },
      { from = "app", to = "general", verdict = "denied", reason = "default" },
      { from = "cicd", to = "general", verdict = "denied", reason = "default" },
    ]
    error_message = "Default deny with no rules should show all pairs denied via default."
  }
}

# default=deny with allow app <-> cicd -> only that pair permitted via allow
run "ipv4_allow_pair_reachability" {
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
    }
  }

  assert {
    condition = output.reachability == [
      { from = "app", to = "cicd", verdict = "permitted", reason = "allow" },
      { from = "app", to = "general", verdict = "denied", reason = "default" },
      { from = "cicd", to = "general", verdict = "denied", reason = "default" },
    ]
    error_message = "Allow app<->cicd should show only that pair permitted via allow."
  }
}

# default=deny with segment [app, cicd] -> same-segment permitted
run "ipv4_segment_reachability" {
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
    condition = output.reachability == [
      { from = "app", to = "cicd", verdict = "permitted", reason = "segment" },
      { from = "app", to = "general", verdict = "denied", reason = "default" },
      { from = "cicd", to = "general", verdict = "denied", reason = "default" },
    ]
    error_message = "Segment workers [app,cicd] should show same-segment pairs permitted via segment."
  }
}

# deny beats allow -> denied pair shows denied:deny
run "ipv4_deny_beats_allow_reachability" {
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
    condition = output.reachability == [
      { from = "app", to = "cicd", verdict = "denied", reason = "deny" },
      { from = "app", to = "general", verdict = "denied", reason = "default" },
      { from = "cicd", to = "general", verdict = "denied", reason = "default" },
    ]
    error_message = "Deny should beat allow for the same pair."
  }
}

# default=allow with two segments -> cross-segment pairs denied
run "ipv4_cross_segment_reachability" {
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
    }
  }

  assert {
    condition = output.reachability == [
      { from = "app", to = "cicd", verdict = "denied", reason = "cross-segment" },
      { from = "app", to = "general", verdict = "permitted", reason = "default" },
      { from = "cicd", to = "general", verdict = "permitted", reason = "default" },
    ]
    error_message = "Cross-segment pairs should be denied:cross-segment, unsegmented should be permitted:default."
  }
}
