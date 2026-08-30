run "setup" {
  module {
    source = "./tests/setup"
  }
}

# provenance traces each route back to its VPC pair and verdict
run "provenance_allow_pair" {
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

  # all routes should trace back to verdict=permitted, reason=allow
  assert {
    condition = alltrue([
      for entry in output.provenance : entry.verdict == "permitted" && entry.reason == "allow"
    ])
    error_message = "All provenance entries should show verdict=permitted, reason=allow."
  }

  # provenance count should match route count
  assert {
    condition     = length(output.provenance) == length(output.ipv4)
    error_message = "Provenance should have one entry per emitted route."
  }

  # each entry has the expected fields
  assert {
    condition = alltrue([
      for entry in output.provenance :
      entry.route_table_id != "" && entry.destination_cidr_block != "" && entry.from != "" && entry.to != ""
    ])
    error_message = "Each provenance entry should have route_table_id, destination_cidr_block, from, and to."
  }
}

# provenance with segments
run "provenance_segment" {
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
    condition = alltrue([
      for entry in output.provenance : entry.verdict == "permitted" && entry.reason == "segment"
    ])
    error_message = "All provenance entries should show verdict=permitted, reason=segment."
  }

  assert {
    condition = alltrue([
      for entry in output.provenance :
      (entry.from == "app" && entry.to == "cicd") || (entry.from == "cicd" && entry.to == "app")
    ])
    error_message = "Provenance should trace back to app<->cicd pair."
  }
}

# empty provenance under full deny
run "provenance_empty_deny" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
      }
    }
  }

  assert {
    condition     = length(output.provenance) == 0
    error_message = "No routes means no provenance."
  }
}
