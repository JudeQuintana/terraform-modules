run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "final_precedence" {
  module {
    source = "./tests/final_precedence"
  }
}

run "final_deny" {
  module {
    source = "./tests/final_deny"
  }
}

run "final" {
  module {
    source = "./tests/final"
  }
}

# default=deny with no allow/segments = zero routes
run "ipv4_default_deny_no_rules" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      default = "deny"
    }
  }

  assert {
    condition     = output.ipv4 == toset([])
    error_message = "Default deny with no rules should produce empty route set."
  }
}

# default=deny with allow app <-> cicd = only those routes
run "ipv4_default_deny_allow_app_cicd" {
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
    condition     = output.ipv4 == run.final_precedence.ipv4_default_deny_allow_app_cicd
    error_message = "Default deny + allow app<->cicd should only permit those routes:\n[\n${join("   \n", [for route in output.ipv4 : format("{\n  destination_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_cidr_block, route.route_table_id)])}\n]"
  }
}

# default=deny with segment "workers" [app, cicd] = only app <-> cicd
run "ipv4_default_deny_segment_workers" {
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
    condition     = output.ipv4 == run.final_precedence.ipv4_default_deny_segment_workers
    error_message = "Default deny + segment workers should only permit app<->cicd:\n[\n${join("   \n", [for route in output.ipv4 : format("{\n  destination_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_cidr_block, route.route_table_id)])}\n]"
  }
}

# deny beats allow: deny app<->cicd AND allow app<->cicd = deny wins
run "ipv4_deny_beats_allow" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
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
    condition     = output.ipv4 == run.final_deny.ipv4_deny_app_to_cicd
    error_message = "Deny should beat allow for the same pair."
  }
}

# allow beats segments: app in "alpha", cicd in "beta" (cross-segment denied),
# allow app<->cicd punches through. general unsegmented, default=allow.
run "ipv4_allow_overrides_segments" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      allow = [
        {
          from = { network_cidr = "10.0.0.0/20" }
          to   = { network_cidr = "172.16.0.0/20" }
        }
      ]
      segments = {
        alpha = [{ network_cidr = "10.0.0.0/20" }]
        beta  = [{ network_cidr = "172.16.0.0/20" }]
      }
    }
  }

  assert {
    condition     = output.ipv4 == run.final_precedence.ipv4_allow_overrides_segments
    error_message = "Allow should override segment cross-deny:\n[\n${join("   \n", [for route in output.ipv4 : format("{\n  destination_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_cidr_block, route.route_table_id)])}\n]"
  }
}

# default=deny with secondary cidrs, allow app <-> cicd only
run "ipv4_with_secondary_cidrs_default_deny_allow_app_cicd" {
  variables {
    vpcs = run.setup.ipv4_with_secondary_cidrs_tiered_vpcs
    routing_policy = {
      default = "deny"
      allow = [
        {
          from = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to   = { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
        }
      ]
    }
  }

  assert {
    condition     = output.ipv4 == run.final_precedence.ipv4_with_secondary_cidrs_default_deny_allow_app_cicd
    error_message = "Default deny + allow app<->cicd with secondary cidrs should only permit those routes:\n[\n${join("   \n", [for route in output.ipv4 : format("{\n  destination_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_cidr_block, route.route_table_id)])}\n]"
  }
}

# default=deny with secondary cidrs, segment "workers" [app, cicd]
run "ipv4_with_secondary_cidrs_default_deny_segment_workers" {
  variables {
    vpcs = run.setup.ipv4_with_secondary_cidrs_tiered_vpcs
    routing_policy = {
      default = "deny"
      segments = {
        workers = [
          { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] },
          { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
        ]
      }
    }
  }

  assert {
    condition     = output.ipv4 == run.final_precedence.ipv4_with_secondary_cidrs_default_deny_segment_workers
    error_message = "Default deny + segment workers with secondary cidrs should only permit app<->cicd:\n[\n${join("   \n", [for route in output.ipv4 : format("{\n  destination_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_cidr_block, route.route_table_id)])}\n]"
  }
}

# deny beats allow with secondary cidrs
run "ipv4_with_secondary_cidrs_deny_beats_allow" {
  variables {
    vpcs = run.setup.ipv4_with_secondary_cidrs_tiered_vpcs
    routing_policy = {
      deny = [
        {
          from = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to   = { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
        }
      ]
      allow = [
        {
          from = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to   = { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
        }
      ]
    }
  }

  assert {
    condition     = output.ipv4 == run.final_deny.ipv4_with_secondary_cidrs_deny_app_to_cicd
    error_message = "Deny should beat allow for the same pair with secondary cidrs."
  }
}

# allow overrides segments with secondary cidrs
run "ipv4_with_secondary_cidrs_allow_overrides_segments" {
  variables {
    vpcs = run.setup.ipv4_with_secondary_cidrs_tiered_vpcs
    routing_policy = {
      allow = [
        {
          from = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to   = { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
        }
      ]
      segments = {
        alpha = [{ network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }]
        beta  = [{ network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }]
      }
    }
  }

  assert {
    condition     = output.ipv4 == run.final_precedence.ipv4_with_secondary_cidrs_allow_overrides_segments
    error_message = "Allow should override segment cross-deny with secondary cidrs:\n[\n${join("   \n", [for route in output.ipv4 : format("{\n  destination_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_cidr_block, route.route_table_id)])}\n]"
  }
}

# combined precedence: deny + allow + segments all active, each pair takes a different path
# deny=[app<->general], allow=[app<->cicd], segments={alpha=[app], beta=[cicd]}, default=allow
# app -> cicd: allowed (allow overrides cross-segment deny)
# app -> general: denied (explicit deny)
# cicd -> general: allowed (default=allow, general unsegmented)
# general -> cicd: allowed (default=allow)
# general -> app: denied (explicit deny)
run "ipv4_combined_precedence" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      deny = [
        {
          from = { network_cidr = "10.0.0.0/20" }
          to   = { network_cidr = "192.168.0.0/20" }
        }
      ]
      allow = [
        {
          from = { network_cidr = "10.0.0.0/20" }
          to   = { network_cidr = "172.16.0.0/20" }
        }
      ]
      segments = {
        alpha = [{ network_cidr = "10.0.0.0/20" }]
        beta  = [{ network_cidr = "172.16.0.0/20" }]
      }
    }
  }

  assert {
    condition     = output.ipv4 == run.final_precedence.ipv4_combined_precedence
    error_message = "Combined precedence failed:\n[\n${join("   \n", [for route in output.ipv4 : format("{\n  destination_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_cidr_block, route.route_table_id)])}\n]"
  }
}

# combined precedence with secondary cidrs
run "ipv4_with_secondary_cidrs_combined_precedence" {
  variables {
    vpcs = run.setup.ipv4_with_secondary_cidrs_tiered_vpcs
    routing_policy = {
      deny = [
        {
          from = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to   = { network_cidr = "192.168.0.0/20" }
        }
      ]
      allow = [
        {
          from = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to   = { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
        }
      ]
      segments = {
        alpha = [{ network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }]
        beta  = [{ network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }]
      }
    }
  }

  assert {
    condition     = output.ipv4 == run.final_precedence.ipv4_with_secondary_cidrs_combined_precedence
    error_message = "Combined precedence with secondary cidrs failed:\n[\n${join("   \n", [for route in output.ipv4 : format("{\n  destination_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_cidr_block, route.route_table_id)])}\n]"
  }
}

# default=allow with empty policy = full mesh (backwards compatible)
run "ipv4_default_allow_empty_policy" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      default = "allow"
    }
  }

  assert {
    condition     = output.ipv4 == run.final.ipv4_set_of_route_objects_to_other_vpcs
    error_message = "Explicit default=allow should produce full mesh."
  }
}

# === IPv6 ===

# default=deny with no allow/segments = zero IPv6 routes
run "ipv6_default_deny_no_rules" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
    routing_policy = {
      default = "deny"
    }
  }

  assert {
    condition     = output.ipv6 == toset([])
    error_message = "Default deny with no rules should produce empty IPv6 route set."
  }
}

# default=deny with allow app <-> cicd = only those IPv6 routes
run "ipv6_default_deny_allow_app_cicd" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
    routing_policy = {
      default = "deny"
      allow = [
        {
          from = { network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56" }
          to   = { network_cidr = "172.16.0.0/20", ipv6_network_cidr = "2600:1f24:66:c200::/56" }
        }
      ]
    }
  }

  assert {
    condition = alltrue([
      for route in output.ipv6 :
      (contains(["rtb-0c92ed73f355dcc65", "rtb-04c6baa3a6a0af91e", "rtb-06836f9bc939ebbce"], route.route_table_id) && route.destination_ipv6_cidr_block == "2600:1f24:66:c200::/56")
      || (contains(["rtb-01e2b1283c7404903", "rtb-0094331bdafb627f3"], route.route_table_id) && route.destination_ipv6_cidr_block == "2600:1f24:66:c100::/56")
    ])
    error_message = "Default deny + allow app<->cicd should only produce app<->cicd IPv6 routes."
  }

  assert {
    condition     = length(output.ipv6) == 5
    error_message = "Should have 5 IPv6 routes (3 app route tables -> cicd + 2 cicd route tables -> app)."
  }
}

# default=deny with segment "workers" [app, cicd] = only app <-> cicd IPv6
run "ipv6_default_deny_segment_workers" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
    routing_policy = {
      default = "deny"
      segments = {
        workers = [
          { network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56" },
          { network_cidr = "172.16.0.0/20", ipv6_network_cidr = "2600:1f24:66:c200::/56" }
        ]
      }
    }
  }

  assert {
    condition = alltrue([
      for route in output.ipv6 :
      (contains(["rtb-0c92ed73f355dcc65", "rtb-04c6baa3a6a0af91e", "rtb-06836f9bc939ebbce"], route.route_table_id) && route.destination_ipv6_cidr_block == "2600:1f24:66:c200::/56")
      || (contains(["rtb-01e2b1283c7404903", "rtb-0094331bdafb627f3"], route.route_table_id) && route.destination_ipv6_cidr_block == "2600:1f24:66:c100::/56")
    ])
    error_message = "Default deny + segment workers should only produce app<->cicd IPv6 routes."
  }

  assert {
    condition     = length(output.ipv6) == 5
    error_message = "Should have 5 IPv6 routes (3 app route tables -> cicd + 2 cicd route tables -> app)."
  }
}

# deny beats allow for IPv6
run "ipv6_deny_beats_allow" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
    routing_policy = {
      deny = [
        {
          from = { network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56" }
          to   = { network_cidr = "172.16.0.0/20", ipv6_network_cidr = "2600:1f24:66:c200::/56" }
        }
      ]
      allow = [
        {
          from = { network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56" }
          to   = { network_cidr = "172.16.0.0/20", ipv6_network_cidr = "2600:1f24:66:c200::/56" }
        }
      ]
    }
  }

  assert {
    condition = !anytrue([
      for route in output.ipv6 :
      contains(["rtb-0c92ed73f355dcc65", "rtb-04c6baa3a6a0af91e", "rtb-06836f9bc939ebbce"], route.route_table_id)
      && route.destination_ipv6_cidr_block == "2600:1f24:66:c200::/56"
    ])
    error_message = "Deny should beat allow for IPv6 — app should not reach cicd."
  }

  assert {
    condition = !anytrue([
      for route in output.ipv6 :
      contains(["rtb-01e2b1283c7404903", "rtb-0094331bdafb627f3"], route.route_table_id)
      && route.destination_ipv6_cidr_block == "2600:1f24:66:c100::/56"
    ])
    error_message = "Deny should beat allow for IPv6 — cicd should not reach app."
  }
}

# allow overrides segments for IPv6
run "ipv6_allow_overrides_segments" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
    routing_policy = {
      allow = [
        {
          from = { network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56" }
          to   = { network_cidr = "172.16.0.0/20", ipv6_network_cidr = "2600:1f24:66:c200::/56" }
        }
      ]
      segments = {
        alpha = [{ network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56" }]
        beta  = [{ network_cidr = "172.16.0.0/20", ipv6_network_cidr = "2600:1f24:66:c200::/56" }]
      }
    }
  }

  assert {
    condition = anytrue([
      for route in output.ipv6 :
      route.route_table_id == "rtb-0c92ed73f355dcc65"
      && route.destination_ipv6_cidr_block == "2600:1f24:66:c200::/56"
    ])
    error_message = "Allow should override segment cross-deny for IPv6 — app should reach cicd."
  }

  assert {
    condition = anytrue([
      for route in output.ipv6 :
      route.route_table_id == "rtb-01e2b1283c7404903"
      && route.destination_ipv6_cidr_block == "2600:1f24:66:c100::/56"
    ])
    error_message = "Allow should override segment cross-deny for IPv6 — cicd should reach app."
  }
}

# combined precedence for IPv6
run "ipv6_combined_precedence" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
    routing_policy = {
      deny = [
        {
          from = { network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56" }
          to   = { network_cidr = "192.168.0.0/20", ipv6_network_cidr = "2600:1f24:66:c300::/56" }
        }
      ]
      allow = [
        {
          from = { network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56" }
          to   = { network_cidr = "172.16.0.0/20", ipv6_network_cidr = "2600:1f24:66:c200::/56" }
        }
      ]
      segments = {
        alpha = [{ network_cidr = "10.0.0.0/20", ipv6_network_cidr = "2600:1f24:66:c100::/56" }]
        beta  = [{ network_cidr = "172.16.0.0/20", ipv6_network_cidr = "2600:1f24:66:c200::/56" }]
      }
    }
  }

  # app -> general: denied (explicit deny)
  assert {
    condition = !anytrue([
      for route in output.ipv6 :
      contains(["rtb-0c92ed73f355dcc65", "rtb-04c6baa3a6a0af91e", "rtb-06836f9bc939ebbce"], route.route_table_id)
      && route.destination_ipv6_cidr_block == "2600:1f24:66:c300::/56"
    ])
    error_message = "App should not reach general IPv6 (explicit deny)."
  }

  # general -> app: denied (explicit deny is bidirectional)
  assert {
    condition = !anytrue([
      for route in output.ipv6 :
      contains(["rtb-066adc27add9a630e", "rtb-0989090af3edb78b1"], route.route_table_id)
      && route.destination_ipv6_cidr_block == "2600:1f24:66:c100::/56"
    ])
    error_message = "General should not reach app IPv6 (explicit deny)."
  }

  # app -> cicd: allowed (allow overrides cross-segment)
  assert {
    condition = anytrue([
      for route in output.ipv6 :
      route.route_table_id == "rtb-0c92ed73f355dcc65"
      && route.destination_ipv6_cidr_block == "2600:1f24:66:c200::/56"
    ])
    error_message = "App should reach cicd IPv6 (allow overrides segments)."
  }

  # cicd -> general: allowed (default=allow, general unsegmented)
  assert {
    condition = anytrue([
      for route in output.ipv6 :
      route.route_table_id == "rtb-01e2b1283c7404903"
      && route.destination_ipv6_cidr_block == "2600:1f24:66:c300::/56"
    ])
    error_message = "Cicd should reach general IPv6 (default=allow, unsegmented)."
  }
}

# default=allow with empty policy = full mesh IPv6
run "ipv6_default_allow_empty_policy" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
    routing_policy = {
      default = "allow"
    }
  }

  assert {
    condition     = output.ipv6 == run.final.ipv6_set_of_route_objects_to_other_vpcs
    error_message = "Explicit default=allow should produce full mesh IPv6."
  }
}
