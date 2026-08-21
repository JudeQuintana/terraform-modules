run "setup" {
  module {
    source = "./tests/setup"
  }
}

# provenance traces each route back to its VPC pair and verdict
run "provenance_allow_pair" {
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

  # app -> cicd routes should all trace back to "permitted:allow"
  assert {
    condition = alltrue([
      for key, reason in output.provenance : strcontains(reason, "permitted:allow")
    ])
    error_message = "All provenance entries should show permitted:allow."
  }

  # provenance count should match route count
  assert {
    condition     = length(output.provenance) == length(output.ipv4)
    error_message = "Provenance should have one entry per emitted route."
  }
}

# provenance with segments
run "provenance_segment" {
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
    condition = alltrue([
      for key, reason in output.provenance : strcontains(reason, "permitted:segment")
    ])
    error_message = "All provenance entries should show permitted:segment."
  }

  assert {
    condition = alltrue([
      for key, reason in output.provenance :
      strcontains(reason, "app -> cicd") || strcontains(reason, "cicd -> app")
    ])
    error_message = "Provenance should trace back to app<->cicd pair."
  }
}

# empty provenance under full deny
run "provenance_empty_deny" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
    routing_policy = {
      default = "deny"
    }
  }

  assert {
    condition     = length(output.provenance) == 0
    error_message = "No routes means no provenance."
  }
}
