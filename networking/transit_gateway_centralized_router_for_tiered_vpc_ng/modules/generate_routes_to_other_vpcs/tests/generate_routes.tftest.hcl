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

# ipv4
run "ipv4_call_with_n_greater_than_one" {
  variables {
    vpcs = run.setup.ipv4_tiered_vpcs
  }

  assert {
    condition     = output.ipv4 == run.final.ipv4_set_of_route_objects_to_other_vpcs
    error_message = "Incorrect set of ipv4 route objects:\n[\n${join("   \n", [for route in output.ipv4 : format("{\n  destination_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_cidr_block, route.route_table_id)])}\n]"
  }
}

run "ipv4_call_with_n_equal_to_one" {
  variables {
    vpcs = run.setup.ipv4_one_tiered_vpc
  }

  assert {
    condition     = output.ipv4 == toset([])
    error_message = "Not an empty set."
  }
}

run "ipv4_call_with_n_equal_to_zero" {
  variables {
    vpcs = {}
  }

  assert {
    condition     = output.ipv4 == toset([])
    error_message = "Not an empty set."
  }
}

run "ipv4_cidr_validation" {
  command = plan

  variables {
    vpcs = run.setup.ipv4_one_tiered_vpc_with_invalid_cidr
  }

  expect_failures = [var.vpcs]
}

# ipv4 with secondary network cidrs
run "ipv4_with_secondary_cidrs_call_with_n_greater_than_one" {
  variables {
    vpcs = run.setup.ipv4_with_secondary_cidrs_tiered_vpcs
  }

  # error message doesnt support showing a set of objects so must build a string to see what's inside the structure
  assert {
    condition     = output.ipv4 == run.final.ipv4_with_secondary_cidrs_set_of_route_objects_to_other_vpcs
    error_message = "Incorrect set of ipv4 with secondary cidrs route objects:\n[\n${join("   \n", [for route in output.ipv4 : format("{\n  destination_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_cidr_block, route.route_table_id)])}\n]"
  }
}

run "ipv4_with_secondary_cidrs_call_with_n_equal_to_one" {
  variables {
    vpcs = run.setup.ipv4_with_secondary_cidrs_one_tiered_vpc
  }

  assert {
    condition     = output.ipv4 == toset([])
    error_message = "Not an empty set."
  }
}

run "ipv4_with_secondary_cidrs_call_with_n_equal_to_zero" {
  variables {
    vpcs = {}
  }

  assert {
    condition     = output.ipv4 == toset([])
    error_message = "Not an empty set."
  }
}

# ipv6
run "ipv6_call_with_n_greater_than_one" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs
  }

  assert {
    condition     = output.ipv6 == run.final.ipv6_set_of_route_objects_to_other_vpcs
    error_message = "Incorrect set of ipv6 route objects:\n[\n${join("   \n", [for route in output.ipv6 : format("{\n  destination_ipv6_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_ipv6_cidr_block, route.route_table_id)])}\n]"
  }
}

run "ipv6_call_with_n_equal_to_one" {
  variables {
    vpcs = run.setup.ipv6_one_tiered_vpc
  }

  assert {
    condition     = output.ipv6 == toset([])
    error_message = "Not an empty set."
  }
}

run "ipv6_call_with_n_equal_to_zero" {
  variables {
    vpcs = {}
  }

  assert {
    condition     = output.ipv6 == toset([])
    error_message = "Not an empty set."
  }
}

run "ipv6_call_with_ipv6_secondary_cidrs_with_n_greater_than_zero" {
  variables {
    vpcs = run.setup.ipv6_tiered_vpcs_with_secondary_cidrs
  }

  assert {
    condition     = output.ipv6 == run.final.ipv6_with_ipv6_secondary_cidrs_set_of_route_objects_to_other_vpcs
    error_message = "Incorrect set of ipv6 route objects with secondary cidrs:\n[\n${join("   \n", [for route in output.ipv6 : format("{\n  destination_ipv6_cidr_block = \"%s\"\n  route_table_id = \"%s\"\n},", route.destination_ipv6_cidr_block, route.route_table_id)])}\n]"
  }
}

run "ipv6_with_secondary_cidrs_call_with_n_equal_to_one" {
  variables {
    vpcs = run.setup.ipv6_with_ipv6_secondary_cidrs_one_tiered_vpc
  }

  assert {
    condition     = output.ipv6 == toset([])
    error_message = "Not an empty set."
  }
}

run "ipv6_with_ipv6_secondary_cidrs_call_with_n_equal_to_zero" {
  variables {
    vpcs = {}
  }

  assert {
    condition     = output.ipv6 == toset([])
    error_message = "Not an empty set."
  }
}
