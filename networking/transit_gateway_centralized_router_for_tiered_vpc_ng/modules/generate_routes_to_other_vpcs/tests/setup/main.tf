# ipv4
output "ipv4_tiered_vpcs" {
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

output "ipv4_one_tiered_vpc" {
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

output "ipv4_one_tiered_vpc_with_invalid_cidr" {
  value = {
    app = {
      network_cidr            = "10.0.0.546/20"
      private_route_table_ids = []
      public_route_table_ids  = []
    }
  }
}

# ipv4 with seondary cidrs
output "ipv4_with_secondary_cidrs_tiered_vpcs" {
  value = {
    app = {
      network_cidr = "10.0.0.0/20"
      private_route_table_ids = [
        "rtb-0c92ed73f355dcc65",
        "rtb-04c6baa3a6a0af91e"
      ]
      public_route_table_ids = [
        "rtb-06836f9bc939ebbce"
      ]
      secondary_cidrs = [
        "10.1.0.0/20",
        "10.2.0.0/20"
      ]
    }
    cicd = {
      network_cidr = "172.16.0.0/20"
      private_route_table_ids = [
        "rtb-01e2b1283c7404903"
      ]
      public_route_table_ids = [
        "rtb-0094331bdafb627f3"
      ]
      secondary_cidrs = [
        "172.17.0.0/20"
      ]
    }
    general = {
      network_cidr = "192.168.0.0/20"
      private_route_table_ids = [
        "rtb-066adc27add9a630e"
      ]
      public_route_table_ids = [
        "rtb-0989090af3edb78b1"
      ]
      secondary_cidrs = []
    }
  }
}

output "ipv4_with_secondary_cidrs_one_tiered_vpc" {
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
      secondary_cidrs = [
        "10.1.0.0/20",
        "10.2.0.0/20"
      ]
    }
  }
}

# ipv6
output "ipv6_tiered_vpcs" {
  value = {
    app = {
      ipv6_network_cidr = "2600:1f24:66:c100::/56"
      network_cidr      = "10.0.0.0/20"
      private_route_table_ids = [
        "rtb-0c92ed73f355dcc65",
        "rtb-04c6baa3a6a0af91e"
      ]
      public_route_table_ids = [
        "rtb-06836f9bc939ebbce"
      ]
      secondary_cidrs = [
        "10.1.0.0/20",
        "10.2.0.0/20"
      ]
    }
    cicd = {
      ipv6_network_cidr = "2600:1f24:66:c200::/56"
      network_cidr      = "172.16.0.0/20"
      private_route_table_ids = [
        "rtb-01e2b1283c7404903"
      ]
      public_route_table_ids = [
        "rtb-0094331bdafb627f3"
      ]
      secondary_cidrs = [
        "172.17.0.0/20"
      ]
    }
    general = {
      ipv6_network_cidr = "2600:1f24:66:c300::/56"
      network_cidr      = "192.168.0.0/20"
      private_route_table_ids = [
        "rtb-066adc27add9a630e"
      ]
      public_route_table_ids = [
        "rtb-0989090af3edb78b1"
      ]
      secondary_cidrs = []
    }
  }
}

output "ipv6_one_tiered_vpc" {
  value = {
    app = {
      ipv6_network_cidr = "2600:1f24:66:c100::/56"
      network_cidr      = "10.0.0.0/20"
      private_route_table_ids = [
        "rtb-0c92ed73f355dcc65",
        "rtb-04c6baa3a6a0af91e"
      ]
      public_route_table_ids = [
        "rtb-06836f9bc939ebbce"
      ]
      secondary_cidrs = [
        "10.1.0.0/20",
        "10.2.0.0/20"
      ]
    }
  }
}
