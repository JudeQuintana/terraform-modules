run "setup" {
  module {
    source = "./tests/setup"
  }
}

# no previous reachability -> null blast radius
run "no_previous_null" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
    }
  }

  assert {
    condition     = output.blast_radius == null
    error_message = "No previous reachability should produce null blast radius."
  }
}

# deny all to full mesh: all pairs added
# app:cicd = 4*1 + 3*1 = 7, app:general = 4*1 + 3*1 = 7, cicd:general = 3*1 + 3*1 = 6
run "deny_all_to_full_mesh" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
      previous_reachability = {
        "app:cicd"     = "denied:default"
        "app:general"  = "denied:default"
        "cicd:app"     = "denied:default"
        "cicd:general" = "denied:default"
        "general:app"  = "denied:default"
        "general:cicd" = "denied:default"
      }
    }
  }

  assert {
    condition     = toset(output.blast_radius.affected_vpcs) == toset(["app", "cicd", "general"])
    error_message = "All 3 VPCs should be affected."
  }

  assert {
    condition     = output.blast_radius.routes_added == 20
    error_message = "Should add 20 routes (7 + 7 + 6)."
  }

  assert {
    condition     = output.blast_radius.routes_removed == 0
    error_message = "No routes should be removed."
  }

  assert {
    condition     = output.blast_radius.pairs_changed == 3
    error_message = "3 pairs should have changed."
  }

  assert {
    condition     = output.blast_radius.route_tables_affected == 10
    error_message = "All 10 route tables should be affected (4 + 3 + 3)."
  }
}

# full mesh to deny all: all pairs removed
run "full_mesh_to_deny_all" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
      }
      previous_reachability = {
        "app:cicd"     = "permitted:default"
        "app:general"  = "permitted:default"
        "cicd:app"     = "permitted:default"
        "cicd:general" = "permitted:default"
        "general:app"  = "permitted:default"
        "general:cicd" = "permitted:default"
      }
    }
  }

  assert {
    condition     = toset(output.blast_radius.affected_vpcs) == toset(["app", "cicd", "general"])
    error_message = "All 3 VPCs should be affected."
  }

  assert {
    condition     = output.blast_radius.routes_added == 0
    error_message = "No routes should be added."
  }

  assert {
    condition     = output.blast_radius.routes_removed == 20
    error_message = "Should remove 20 routes (7 + 7 + 6)."
  }

  assert {
    condition     = output.blast_radius.pairs_changed == 3
    error_message = "3 pairs should have changed."
  }

  assert {
    condition     = output.blast_radius.route_tables_affected == 10
    error_message = "All 10 route tables should be affected."
  }
}

# selective: one pair added via segment under deny
# previous: all denied. new: segment [app, cicd] under deny -> app:cicd added
# app:cicd = 4*1 + 3*1 = 7 routes
run "selective_add" {
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
      previous_reachability = {
        "app:cicd"     = "denied:default"
        "app:general"  = "denied:default"
        "cicd:app"     = "denied:default"
        "cicd:general" = "denied:default"
        "general:app"  = "denied:default"
        "general:cicd" = "denied:default"
      }
    }
  }

  assert {
    condition     = toset(output.blast_radius.affected_vpcs) == toset(["app", "cicd"])
    error_message = "Only app and cicd should be affected."
  }

  assert {
    condition     = output.blast_radius.routes_added == 7
    error_message = "Should add 7 routes (4 + 3)."
  }

  assert {
    condition     = output.blast_radius.routes_removed == 0
    error_message = "No routes should be removed."
  }

  assert {
    condition     = output.blast_radius.pairs_changed == 1
    error_message = "1 pair should have changed."
  }

  assert {
    condition     = output.blast_radius.route_tables_affected == 7
    error_message = "7 route tables should be affected (4 + 3)."
  }
}

# no change: same policy -> zero impact
run "no_change" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
      previous_reachability = {
        "app:cicd"     = "permitted:default"
        "app:general"  = "permitted:default"
        "cicd:app"     = "permitted:default"
        "cicd:general" = "permitted:default"
        "general:app"  = "permitted:default"
        "general:cicd" = "permitted:default"
      }
    }
  }

  assert {
    condition     = length(output.blast_radius.affected_vpcs) == 0
    error_message = "No VPCs should be affected."
  }

  assert {
    condition     = output.blast_radius.routes_added == 0
    error_message = "No routes should be added."
  }

  assert {
    condition     = output.blast_radius.routes_removed == 0
    error_message = "No routes should be removed."
  }

  assert {
    condition     = output.blast_radius.pairs_changed == 0
    error_message = "No pairs should have changed."
  }

  assert {
    condition     = output.blast_radius.route_tables_affected == 0
    error_message = "No route tables should be affected."
  }
}

# mixed: swap connectivity (app:cicd removed, app:general added)
run "mixed_add_remove" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
        allow = [
          { from = { network_cidr = "10.0.0.0/20" }, to = { network_cidr = "192.168.0.0/20" } }
        ]
      }
      previous_reachability = {
        "app:cicd"     = "permitted:allow"
        "app:general"  = "denied:default"
        "cicd:app"     = "permitted:allow"
        "cicd:general" = "denied:default"
        "general:app"  = "denied:default"
        "general:cicd" = "denied:default"
      }
    }
  }

  assert {
    condition     = toset(output.blast_radius.affected_vpcs) == toset(["app", "cicd", "general"])
    error_message = "All 3 VPCs should be affected."
  }

  assert {
    condition     = output.blast_radius.routes_added == 7
    error_message = "Should add 7 routes for app:general (4 + 3)."
  }

  assert {
    condition     = output.blast_radius.routes_removed == 7
    error_message = "Should remove 7 routes for app:cicd (4 + 3)."
  }

  assert {
    condition     = output.blast_radius.pairs_changed == 2
    error_message = "2 pairs should have changed."
  }

  assert {
    condition     = output.blast_radius.route_tables_affected == 10
    error_message = "All 10 route tables should be affected."
  }
}

# secondary CIDRs inflate route counts
# app: 3 route tables, 3 CIDRs. cicd: 2 route tables, 2 CIDRs. general: 2 route tables, 1 CIDR.
# app:cicd = 3*2 + 2*3 = 12, app:general = 3*1 + 2*3 = 9, cicd:general = 2*1 + 2*2 = 6
run "secondary_cidrs_affect_route_count" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_with_secondary_cidrs_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
      previous_reachability = {
        "app:cicd"     = "denied:default"
        "app:general"  = "denied:default"
        "cicd:app"     = "denied:default"
        "cicd:general" = "denied:default"
        "general:app"  = "denied:default"
        "general:cicd" = "denied:default"
      }
    }
  }

  assert {
    condition     = output.blast_radius.routes_added == 27
    error_message = "Should add 27 routes (12 + 9 + 6) with secondary CIDRs."
  }

  assert {
    condition     = output.blast_radius.route_tables_affected == 7
    error_message = "7 route tables should be affected (3 + 2 + 2)."
  }

  assert {
    condition     = output.blast_radius.pairs_changed == 3
    error_message = "3 pairs should have changed."
  }
}
