terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

# Multiple routes for a map with more than one tiered vpc
locals {
  tiered_vpcs = {
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
    cicd = {
      network_cidr = "172.31.0.0/20"
      private_route_table_ids = [
        "rtb-0f8deb7a6682793e2"
      ]
      public_route_table_ids = [
        "rtb-09a4481eb3684abba"
      ]
    }
    general = {
      network_cidr = "192.168.0.0/20"
      private_route_table_ids = [
        "rtb-01e5ec4882154a9a1"
      ]
      public_route_table_ids = [
        "rtb-0ad6cde89a9e386fd"
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
    "rtb-01e5ec4882154a9a1|10.0.0.0/20"    = "10.0.0.0/20"
    "rtb-01e5ec4882154a9a1|172.31.0.0/20"  = "172.31.0.0/20"
    "rtb-02ad79df1a7c192e7|172.31.0.0/20"  = "172.31.0.0/20"
    "rtb-02ad79df1a7c192e7|192.168.0.0/20" = "192.168.0.0/20"
    "rtb-0468efad92cd62ab8|172.31.0.0/20"  = "172.31.0.0/20"
    "rtb-0468efad92cd62ab8|192.168.0.0/20" = "192.168.0.0/20"
    "rtb-06b216fb818494594|172.31.0.0/20"  = "172.31.0.0/20"
    "rtb-06b216fb818494594|192.168.0.0/20" = "192.168.0.0/20"
    "rtb-09a4481eb3684abba|10.0.0.0/20"    = "10.0.0.0/20"
    "rtb-09a4481eb3684abba|192.168.0.0/20" = "192.168.0.0/20"
    "rtb-0ad6cde89a9e386fd|10.0.0.0/20"    = "10.0.0.0/20"
    "rtb-0ad6cde89a9e386fd|172.31.0.0/20"  = "172.31.0.0/20"
    "rtb-0f8deb7a6682793e2|10.0.0.0/20"    = "10.0.0.0/20"
    "rtb-0f8deb7a6682793e2|192.168.0.0/20" = "192.168.0.0/20"
  }

  set_of_route_objects_to_other_vpcs = toset([
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-01e5ec4882154a9a1"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-09a4481eb3684abba"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0ad6cde89a9e386fd"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0f8deb7a6682793e2"
    },
    {
      destination_cidr_block = "172.31.0.0/20"
      route_table_id         = "rtb-01e5ec4882154a9a1"
    },
    {
      destination_cidr_block = "172.31.0.0/20"
      route_table_id         = "rtb-02ad79df1a7c192e7"
    },
    {
      destination_cidr_block = "172.31.0.0/20"
      route_table_id         = "rtb-0468efad92cd62ab8"
    },
    {
      destination_cidr_block = "172.31.0.0/20"
      route_table_id         = "rtb-06b216fb818494594"
    },
    {
      destination_cidr_block = "172.31.0.0/20"
      route_table_id         = "rtb-0ad6cde89a9e386fd"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-02ad79df1a7c192e7"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-0468efad92cd62ab8"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-06b216fb818494594"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-09a4481eb3684abba"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-0f8deb7a6682793e2"
    },
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

