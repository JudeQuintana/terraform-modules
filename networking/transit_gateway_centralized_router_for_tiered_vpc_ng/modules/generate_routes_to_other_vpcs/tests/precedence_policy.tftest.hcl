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
    policy = {
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
    policy = {
      default = "deny"
      allow = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20" }
          to_vpc   = { network_cidr = "172.16.0.0/20" }
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
    policy = {
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
    policy = {
      deny = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20" }
          to_vpc   = { network_cidr = "172.16.0.0/20" }
        }
      ]
      allow = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20" }
          to_vpc   = { network_cidr = "172.16.0.0/20" }
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
    policy = {
      allow = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20" }
          to_vpc   = { network_cidr = "172.16.0.0/20" }
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
    policy = {
      default = "deny"
      allow = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to_vpc   = { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
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
    policy = {
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
    policy = {
      deny = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to_vpc   = { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
        }
      ]
      allow = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to_vpc   = { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
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
    policy = {
      allow = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to_vpc   = { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
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
    policy = {
      deny = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20" }
          to_vpc   = { network_cidr = "192.168.0.0/20" }
        }
      ]
      allow = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20" }
          to_vpc   = { network_cidr = "172.16.0.0/20" }
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
    policy = {
      deny = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to_vpc   = { network_cidr = "192.168.0.0/20" }
        }
      ]
      allow = [
        {
          from_vpc = { network_cidr = "10.0.0.0/20", secondary_cidrs = ["10.1.0.0/20", "10.2.0.0/20"] }
          to_vpc   = { network_cidr = "172.16.0.0/20", secondary_cidrs = ["172.17.0.0/20"] }
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
    policy = {
      default = "allow"
    }
  }

  assert {
    condition     = output.ipv4 == run.final.ipv4_set_of_route_objects_to_other_vpcs
    error_message = "Explicit default=allow should produce full mesh."
  }
}
