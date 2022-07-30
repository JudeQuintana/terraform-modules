terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

locals {
  tiered_vpcs = {
    app = {
      az_to_private_route_table_id = {
        a = "rtb-0468efad92cd62ab8"
        b = "rtb-02ad79df1a7c192e7"
      }
      az_to_public_route_table_id = {
        a = "rtb-06b216fb818494594"
        b = "rtb-06b216fb818494594"
      }
      network = "10.0.0.0/20"
    }
    cicd = {
      az_to_private_route_table_id = {
        a = "rtb-0f8deb7a6682793e2"
      }
      az_to_public_route_table_id = {
        a = "rtb-09a4481eb3684abba"
      }
      network = "172.31.0.0/20"
    }
    general = {
      az_to_private_route_table_id = {
        c = "rtb-01e5ec4882154a9a1"
      }
      az_to_public_route_table_id = {
        c = "rtb-0ad6cde89a9e386fd"
      }
      network = "192.168.0.0/20"
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

resource "test_assertions" "generate_routes_to_other_vpcs" {
  component = "generate_routes_to_other_vpcs"

  equal "map_of_routes_to_other_vpcs" {
    description = "generated map of routes"
    got         = module.main.call_legacy
    want        = local.map_of_routes_to_other_vpcs
  }

  equal "set_of_route_objects_to_other_vpcs" {
    description = "generated set of route objects"
    got         = module.main.call
    want        = local.set_of_route_objects_to_other_vpcs
  }
}
