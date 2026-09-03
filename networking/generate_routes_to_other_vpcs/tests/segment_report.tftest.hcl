run "setup" {
  module {
    source = "./tests/setup"
  }
}

# full mesh: all VPCs reach each other, no segments
run "full_mesh" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
      }
    }
  }

  assert {
    condition     = length(output.segment_report) == 3
    error_message = "Should have 3 VPC entries."
  }

  assert {
    condition     = output.segment_report["app"].segment == null
    error_message = "App should have no segment."
  }

  assert {
    condition     = toset(output.segment_report["app"].reaches) == toset(["cicd", "general"])
    error_message = "App should reach cicd and general."
  }

  assert {
    condition     = length(output.segment_report["app"].denied) == 0
    error_message = "App should have no denied VPCs."
  }

  assert {
    condition     = length(output.segment_report["general"].denied) == 0
    error_message = "General should have no denied VPCs."
  }
}

# zero trust: no VPCs reach each other
run "zero_trust" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
      }
    }
  }

  assert {
    condition     = length(output.segment_report["app"].reaches) == 0
    error_message = "App should reach nothing."
  }

  assert {
    condition     = toset(output.segment_report["app"].denied) == toset(["cicd", "general"])
    error_message = "App should be denied from cicd and general."
  }

  assert {
    condition     = toset(output.segment_report["cicd"].denied) == toset(["app", "general"])
    error_message = "Cicd should be denied from app and general."
  }
}

# segments: workers segment [app, cicd] under deny
run "with_segments" {
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
    condition     = output.segment_report["app"].segment == "workers"
    error_message = "App should be in workers segment."
  }

  assert {
    condition     = output.segment_report["cicd"].segment == "workers"
    error_message = "Cicd should be in workers segment."
  }

  assert {
    condition     = output.segment_report["general"].segment == null
    error_message = "General should have no segment."
  }

  assert {
    condition     = toset(output.segment_report["app"].reaches) == toset(["cicd"])
    error_message = "App should only reach cicd."
  }

  assert {
    condition     = toset(output.segment_report["app"].denied) == toset(["general"])
    error_message = "App should be denied from general."
  }

  assert {
    condition     = length(output.segment_report["general"].reaches) == 0
    error_message = "General should reach nothing."
  }

  assert {
    condition     = toset(output.segment_report["general"].denied) == toset(["app", "cicd"])
    error_message = "General should be denied from app and cicd."
  }
}

# allow rule: default=deny, allow app->general
run "with_allow_rule" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
        allow = [
          { from = { network_cidr = "10.0.0.0/20" }, to = { network_cidr = "192.168.0.0/20" } }
        ]
      }
    }
  }

  assert {
    condition     = toset(output.segment_report["app"].reaches) == toset(["general"])
    error_message = "App should reach general."
  }

  assert {
    condition     = toset(output.segment_report["app"].denied) == toset(["cicd"])
    error_message = "App should be denied from cicd."
  }

  assert {
    condition     = toset(output.segment_report["general"].reaches) == toset(["app"])
    error_message = "General should reach app (bidirectional)."
  }

  assert {
    condition     = toset(output.segment_report["cicd"].denied) == toset(["app", "general"])
    error_message = "Cicd should be denied from app and general."
  }
}

# deny rule: default=allow, deny app->cicd
run "with_deny_rule" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
        deny = [
          { from = { network_cidr = "10.0.0.0/20" }, to = { network_cidr = "172.16.0.0/20" } }
        ]
      }
    }
  }

  assert {
    condition     = toset(output.segment_report["app"].reaches) == toset(["general"])
    error_message = "App should only reach general."
  }

  assert {
    condition     = toset(output.segment_report["app"].denied) == toset(["cicd"])
    error_message = "App should be denied from cicd."
  }

  assert {
    condition     = toset(output.segment_report["cicd"].denied) == toset(["app"])
    error_message = "Cicd should be denied from app."
  }

  assert {
    condition     = toset(output.segment_report["general"].reaches) == toset(["app", "cicd"])
    error_message = "General should reach both app and cicd."
  }

  assert {
    condition     = length(output.segment_report["general"].denied) == 0
    error_message = "General should have no denied VPCs."
  }
}

# multiple segments: cross-segment deny under default=allow
run "multiple_segments" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "allow"
        segments = {
          frontend = [
            { network_cidr = "10.0.0.0/20" }
          ]
          backend = [
            { network_cidr = "172.16.0.0/20" }
          ]
        }
      }
    }
  }

  assert {
    condition     = output.segment_report["app"].segment == "frontend"
    error_message = "App should be in frontend segment."
  }

  assert {
    condition     = output.segment_report["cicd"].segment == "backend"
    error_message = "Cicd should be in backend segment."
  }

  assert {
    condition     = output.segment_report["general"].segment == null
    error_message = "General should have no segment."
  }

  assert {
    condition     = toset(output.segment_report["app"].reaches) == toset(["general"])
    error_message = "App should reach general (unsegmented)."
  }

  assert {
    condition     = toset(output.segment_report["app"].denied) == toset(["cicd"])
    error_message = "App should be denied from cicd (cross-segment)."
  }

  assert {
    condition     = toset(output.segment_report["general"].reaches) == toset(["app", "cicd"])
    error_message = "General (unsegmented) should reach both segmented VPCs."
  }
}

# single VPC: no others to reach or deny
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
    condition     = length(output.segment_report) == 1
    error_message = "Should have 1 VPC entry."
  }

  assert {
    condition     = output.segment_report["app"].segment == null
    error_message = "App should have no segment."
  }

  assert {
    condition     = length(output.segment_report["app"].reaches) == 0
    error_message = "App should have no VPCs to reach."
  }

  assert {
    condition     = length(output.segment_report["app"].denied) == 0
    error_message = "App should have no denied VPCs."
  }
}
