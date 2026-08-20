run "setup" {
  module {
    source = "./tests/setup"
  }
}

# default=allow (full mesh) -> all pairs permitted via default
run "ipv4_full_mesh_reachability" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      default = "allow"
    }
  }

  assert {
    condition = output.reachability.ipv4 == {
      "app:cicd"      = "permitted:default"
      "app:general"   = "permitted:default"
      "cicd:app"      = "permitted:default"
      "cicd:general"  = "permitted:default"
      "general:app"   = "permitted:default"
      "general:cicd"  = "permitted:default"
    }
    error_message = "Default allow should show all pairs permitted via default."
  }
}

# default=deny with no rules -> all pairs denied via default
run "ipv4_zero_trust_reachability" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      default = "deny"
    }
  }

  assert {
    condition = output.reachability.ipv4 == {
      "app:cicd"      = "denied:default"
      "app:general"   = "denied:default"
      "cicd:app"      = "denied:default"
      "cicd:general"  = "denied:default"
      "general:app"   = "denied:default"
      "general:cicd"  = "denied:default"
    }
    error_message = "Default deny with no rules should show all pairs denied via default."
  }
}

# default=deny with allow app <-> cicd -> only that pair permitted via allow
run "ipv4_allow_pair_reachability" {
  variables {
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

  assert {
    condition = output.reachability.ipv4 == {
      "app:cicd"      = "permitted:allow"
      "app:general"   = "denied:default"
      "cicd:app"      = "permitted:allow"
      "cicd:general"  = "denied:default"
      "general:app"   = "denied:default"
      "general:cicd"  = "denied:default"
    }
    error_message = "Allow app<->cicd should show only that pair permitted via allow."
  }
}

# default=deny with segment [app, cicd] -> same-segment permitted
run "ipv4_segment_reachability" {
  variables {
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

  assert {
    condition = output.reachability.ipv4 == {
      "app:cicd"      = "permitted:segment"
      "app:general"   = "denied:default"
      "cicd:app"      = "permitted:segment"
      "cicd:general"  = "denied:default"
      "general:app"   = "denied:default"
      "general:cicd"  = "denied:default"
    }
    error_message = "Segment workers [app,cicd] should show same-segment pairs permitted via segment."
  }
}

# deny beats allow -> denied pair shows denied:deny
run "ipv4_deny_beats_allow_reachability" {
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
      allow = [
        {
          from = { network_cidr = "10.0.0.0/20" }
          to   = { network_cidr = "172.16.0.0/20" }
        }
      ]
    }
  }

  assert {
    condition = output.reachability.ipv4 == {
      "app:cicd"      = "denied:deny"
      "app:general"   = "denied:default"
      "cicd:app"      = "denied:deny"
      "cicd:general"  = "denied:default"
      "general:app"   = "denied:default"
      "general:cicd"  = "denied:default"
    }
    error_message = "Deny should beat allow for the same pair."
  }
}

# default=allow with two segments -> cross-segment pairs denied
run "ipv4_cross_segment_reachability" {
  variables {
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

  assert {
    condition = output.reachability.ipv4 == {
      "app:cicd"      = "denied:cross-segment"
      "app:general"   = "permitted:default"
      "cicd:app"      = "denied:cross-segment"
      "cicd:general"  = "permitted:default"
      "general:app"   = "permitted:default"
      "general:cicd"  = "permitted:default"
    }
    error_message = "Cross-segment pairs should be denied:cross-segment, unsegmented should be permitted:default."
  }
}

# ipv6 full mesh reachability
run "ipv6_full_mesh_reachability" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
    routing_policy = {
      default = "allow"
    }
  }

  assert {
    condition = output.reachability.ipv6 == {
      "app:cicd"      = "permitted:default"
      "app:general"   = "permitted:default"
      "cicd:app"      = "permitted:default"
      "cicd:general"  = "permitted:default"
      "general:app"   = "permitted:default"
      "general:cicd"  = "permitted:default"
    }
    error_message = "IPv6 default allow should show all pairs permitted via default."
  }
}

# ipv6 default=deny -> all pairs denied via default
run "ipv6_zero_trust_reachability" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
    routing_policy = {
      default = "deny"
    }
  }

  assert {
    condition = output.reachability.ipv6 == {
      "app:cicd"      = "denied:default"
      "app:general"   = "denied:default"
      "cicd:app"      = "denied:default"
      "cicd:general"  = "denied:default"
      "general:app"   = "denied:default"
      "general:cicd"  = "denied:default"
    }
    error_message = "IPv6 default deny should show all pairs denied via default."
  }
}
