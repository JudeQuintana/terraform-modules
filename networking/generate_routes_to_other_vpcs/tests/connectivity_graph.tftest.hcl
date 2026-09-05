run "setup" {
  module {
    source = "./tests/setup"
  }
}

# full mesh: 3 nodes, 3 edges with "default" label
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
    condition     = strcontains(output.connectivity_graph, "graph connectivity {")
    error_message = "Should have graph declaration."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "\"app\"")
    error_message = "Should contain app node."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "\"cicd\"")
    error_message = "Should contain cicd node."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "\"general\"")
    error_message = "Should contain general node."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "\"app\" -- \"cicd\"")
    error_message = "Should have app-cicd edge."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "\"app\" -- \"general\"")
    error_message = "Should have app-general edge."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "\"cicd\" -- \"general\"")
    error_message = "Should have cicd-general edge."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "label=\"default\"")
    error_message = "Edges should have default label."
  }
}

# deny all: nodes present but no edges
run "deny_all_no_edges" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
      }
    }
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "\"app\"")
    error_message = "Should contain app node."
  }

  assert {
    condition     = !strcontains(output.connectivity_graph, " -- ")
    error_message = "Should have no edges."
  }
}

# segment cluster: subgraph and segment-colored edge
run "with_segment_cluster" {
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
    condition     = strcontains(output.connectivity_graph, "subgraph cluster_workers")
    error_message = "Should have cluster_workers subgraph."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "label=\"workers\"")
    error_message = "Cluster should be labeled workers."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "\"app\" -- \"cicd\"")
    error_message = "Should have app-cicd edge."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "label=\"segment\"")
    error_message = "Edge should have segment label."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "color=\"#2ecc71\"")
    error_message = "Segment edge should be green."
  }
}

# allow rule edge
run "with_allow_edge" {
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
    condition     = strcontains(output.connectivity_graph, "\"app\" -- \"general\"")
    error_message = "Should have app-general edge."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "label=\"allow\"")
    error_message = "Edge should have allow label."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "color=\"#3498db\"")
    error_message = "Allow edge should be blue."
  }

  assert {
    condition     = !strcontains(output.connectivity_graph, "\"cicd\" -- \"general\"")
    error_message = "Should not have cicd-general edge."
  }
}

# mixed: segment + allow edges in same graph
run "mixed_edge_types" {
  variables {
    generate_routes_to_other_vpcs = {
      vpcs = run.setup.ipv4_tiered_vpcs
      routing_policy = {
        default = "deny"
        allow = [
          { from = { network_cidr = "10.0.0.0/20" }, to = { network_cidr = "192.168.0.0/20" } }
        ]
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
    condition     = strcontains(output.connectivity_graph, "subgraph cluster_workers")
    error_message = "Should have cluster_workers subgraph."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "label=\"segment\"")
    error_message = "Should have segment edge."
  }

  assert {
    condition     = strcontains(output.connectivity_graph, "label=\"allow\"")
    error_message = "Should have allow edge."
  }

  assert {
    condition     = !strcontains(output.connectivity_graph, "\"cicd\" -- \"general\"")
    error_message = "cicd-general should not be connected."
  }
}

# single VPC: one node, no edges
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
    condition     = strcontains(output.connectivity_graph, "\"app\"")
    error_message = "Should contain app node."
  }

  assert {
    condition     = !strcontains(output.connectivity_graph, " -- ")
    error_message = "Should have no edges with single VPC."
  }
}
