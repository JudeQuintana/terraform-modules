run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "final" {
  module {
    source = "./tests/final"
  }
}

run "generate_routes_to_other_vpcs_call_with_n_greater_than_one" {
  variables {
    vpcs = run.setup.tiered_vpcs
  }

  assert {
    condition     = output.call == run.final.set_of_route_objects_to_other_vpcs
    error_message = "Incorrect set of route objects."
  }
}

run "generate_routes_to_other_vpcs_call_with_n_equal_to_one" {
  variables {
    vpcs = run.setup.one_tiered_vpc
  }

  assert {
    condition     = output.call == toset([])
    error_message = "Not an empty set."
  }
}

run "generate_routes_to_other_vpcs_call_with_n_equal_to_zero" {
  variables {
    vpcs = {}
  }

  assert {
    condition     = output.call == toset([])
    error_message = "Not an empty set."
  }
}

