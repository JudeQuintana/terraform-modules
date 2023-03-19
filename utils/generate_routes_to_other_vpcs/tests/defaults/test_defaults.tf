terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

# Multiple private and route table ids for a vpc network cidr
locals {
  tiered_vpcs = {
    app = {
      network_cidr = "10.0.0.0/20"
      private_route_table_ids = [
        "rtb-09210b506aad8cccc",
        "rtb-0707c5783a639c0be",
        "rtb-0059681f31f6819f6"
      ]
      public_route_table_ids = [
        "rtb-0b0b9d1c342f155a9",
        "rtb-0b0b9d1c342f155a9",
        "rtb-0b0b9d1c342f155a9"
      ]
    }
    cicd = {
      network_cidr = "172.16.0.0/20"
      private_route_table_ids = [
        "rtb-0e36393dc78c51235",
        "rtb-0bdbabf9e8e133fa8"
      ]
      public_route_table_ids = [
        "rtb-026bb809ef2dcbf02",
        "rtb-026bb809ef2dcbf02"
      ]
    }
    general = {
      network_cidr = "192.168.0.0/20"
      private_route_table_ids = [
        "rtb-0edcf7e461359d8b2",
        "rtb-0afd28d1d8cae5563"
      ]
      public_route_table_ids = [
        "rtb-0a97d8dd5f739f7bc",
        "rtb-0a97d8dd5f739f7bc"
      ]
    }
  }
}

module "main" {
  source = "../.."

  vpcs = local.tiered_vpcs
}

locals {
  map_of_routes_to_other_vpcs = {
    "rtb-0059681f31f6819f6|172.16.0.0/20"  = "172.16.0.0/20"
    "rtb-0059681f31f6819f6|192.168.0.0/20" = "192.168.0.0/20"
    "rtb-026bb809ef2dcbf02|10.0.0.0/20"    = "10.0.0.0/20"
    "rtb-026bb809ef2dcbf02|192.168.0.0/20" = "192.168.0.0/20"
    "rtb-0707c5783a639c0be|172.16.0.0/20"  = "172.16.0.0/20"
    "rtb-0707c5783a639c0be|192.168.0.0/20" = "192.168.0.0/20"
    "rtb-09210b506aad8cccc|172.16.0.0/20"  = "172.16.0.0/20"
    "rtb-09210b506aad8cccc|192.168.0.0/20" = "192.168.0.0/20"
    "rtb-0a97d8dd5f739f7bc|10.0.0.0/20"    = "10.0.0.0/20"
    "rtb-0a97d8dd5f739f7bc|172.16.0.0/20"  = "172.16.0.0/20"
    "rtb-0afd28d1d8cae5563|10.0.0.0/20"    = "10.0.0.0/20"
    "rtb-0afd28d1d8cae5563|172.16.0.0/20"  = "172.16.0.0/20"
    "rtb-0b0b9d1c342f155a9|172.16.0.0/20"  = "172.16.0.0/20"
    "rtb-0b0b9d1c342f155a9|192.168.0.0/20" = "192.168.0.0/20"
    "rtb-0bdbabf9e8e133fa8|10.0.0.0/20"    = "10.0.0.0/20"
    "rtb-0bdbabf9e8e133fa8|192.168.0.0/20" = "192.168.0.0/20"
    "rtb-0e36393dc78c51235|10.0.0.0/20"    = "10.0.0.0/20"
    "rtb-0e36393dc78c51235|192.168.0.0/20" = "192.168.0.0/20"
    "rtb-0edcf7e461359d8b2|10.0.0.0/20"    = "10.0.0.0/20"
    "rtb-0edcf7e461359d8b2|172.16.0.0/20"  = "172.16.0.0/20"
  }

  set_of_route_objects_to_other_vpcs = toset([
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-026bb809ef2dcbf02"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0a97d8dd5f739f7bc"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0afd28d1d8cae5563"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0bdbabf9e8e133fa8"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0e36393dc78c51235"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0edcf7e461359d8b2"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-0059681f31f6819f6"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-0707c5783a639c0be"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-09210b506aad8cccc"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-0a97d8dd5f739f7bc"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-0afd28d1d8cae5563"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-0b0b9d1c342f155a9"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-0edcf7e461359d8b2"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-0059681f31f6819f6"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-026bb809ef2dcbf02"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-0707c5783a639c0be"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-09210b506aad8cccc"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-0b0b9d1c342f155a9"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-0bdbabf9e8e133fa8"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-0e36393dc78c51235"
    }
  ])
}

resource "test_assertions" "generate_routes_to_other_vpcs_call_with_n_greater_than_1" {
  component = "generate_routes_to_other_vpcs"

  equal "map_of_routes_to_other_vpcs" {
    description = "generated map of generically defined routes"
    got         = module.main.call_legacy
    want        = local.map_of_routes_to_other_vpcs
  }

  equal "set_of_route_objects_to_other_vpcs" {
    description = "generated set of route objects"
    got         = module.main.call
    want        = local.set_of_route_objects_to_other_vpcs
  }
}

# Empty set for map with one tiered vpc
locals {
  one_tiered_vpc = {
    app = {
      network_cidr = "10.0.0.0/20"
      private_route_table_ids = [
        "rtb-0468efad92cd62ab8",
        "rtb-02ad79df1a7c192e7"
      ]
      public_route_table_ids = [
        "rtb-06b216fb818494594",
        "rtb-06b216fb818494594"
      ]
    }
  }
}

module "main_with_n_equal_to_1" {
  source = "../.."

  vpcs = local.one_tiered_vpc
}

resource "test_assertions" "generate_routes_to_other_vpcs_with_n_equal_to_1" {
  component = "generate_routes_to_other_vpcs_with_n_equal_to_1"

  equal "empty_set" {
    description = "empty set of routes objects"
    got         = module.main_with_n_equal_to_1.call
    want        = toset([])
  }
}

# Empty set for empty map
locals {
  zero_tiered_vpc = {}
}

module "main_with_n_equal_to_0" {
  source = "../.."

  vpcs = local.zero_tiered_vpc
}

resource "test_assertions" "generate_routes_to_other_vpcs_with_n_equal_to_0" {
  component = "generate_routes_to_other_vpcs_with_n_equal_to_0"

  equal "empty_set" {
    description = "empty set of routes objects"
    got         = module.main_with_n_equal_to_0.call
    want        = toset([])
  }
}

