# segments: app in "alpha", cicd in "beta", general unsegmented
# cross-segment: app <-> cicd denied
# unsegmented: general routes to both app and cicd
# same result as deny app <-> cicd
output "ipv4_two_segments_general_unsegmented" {
  value = toset([
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-0059681f31f6819f6"
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
      route_table_id         = "rtb-026bb809ef2dcbf02"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-0bdbabf9e8e133fa8"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-0e36393dc78c51235"
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
      route_table_id         = "rtb-0edcf7e461359d8b2"
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
      route_table_id         = "rtb-0edcf7e461359d8b2"
    },
  ])
}

# segments: all three in separate segments = total isolation
output "ipv4_all_separate_segments" {
  value = toset([])
}

# segments with secondary cidrs: app in "alpha", cicd in "beta", general unsegmented
# cross-segment: app <-> cicd denied (all cidrs including secondaries)
# unsegmented: general routes to all
output "ipv4_with_secondary_cidrs_two_segments_general_unsegmented" {
  value = toset([
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-04c6baa3a6a0af91e"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-06836f9bc939ebbce"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-0c92ed73f355dcc65"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-0094331bdafb627f3"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-01e2b1283c7404903"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-066adc27add9a630e"
    },
    {
      destination_cidr_block = "10.1.0.0/20"
      route_table_id         = "rtb-066adc27add9a630e"
    },
    {
      destination_cidr_block = "10.2.0.0/20"
      route_table_id         = "rtb-066adc27add9a630e"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-066adc27add9a630e"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-066adc27add9a630e"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0989090af3edb78b1"
    },
    {
      destination_cidr_block = "10.1.0.0/20"
      route_table_id         = "rtb-0989090af3edb78b1"
    },
    {
      destination_cidr_block = "10.2.0.0/20"
      route_table_id         = "rtb-0989090af3edb78b1"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-0989090af3edb78b1"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-0989090af3edb78b1"
    },
  ])
}

# segments with secondary cidrs: all separate segments = total isolation
output "ipv4_with_secondary_cidrs_all_separate_segments" {
  value = toset([])
}
