output "tiered_vpcs" {
  value = {
    app = {
      network_cidr = "10.0.0.0/20"
      private_route_table_ids = [
        "rtb-09210b506aad8cccc",
        "rtb-0707c5783a639c0be",
        "rtb-0059681f31f6819f6"
      ]
      public_route_table_ids = [
        "rtb-0b0b9d1c342f155a9",
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
      ]
    }
  }
}

output "one_tiered_vpc" {
  value = {
    app = {
      network_cidr = "10.0.0.0/20"
      private_route_table_ids = [
        "rtb-0468efad92cd62ab8",
        "rtb-02ad79df1a7c192e7"
      ]
      public_route_table_ids = [
        "rtb-06b216fb818494594",
      ]
    }
  }
}

output "one_tiered_vpc_with_invalid_cidr" {
  value = {
    app = {
      network_cidr            = "10.0.0.546/20"
      private_route_table_ids = []
      public_route_table_ids  = []
    }
  }
}

