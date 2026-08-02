# deny app <-> cicd: app route tables lose 172.16.0.0/20, cicd route tables lose 10.0.0.0/20
# general is unaffected (still gets both)
output "ipv4_deny_app_to_cicd" {
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

# deny with secondary cidrs: deny app (10.0.0.0/20 + 10.1.0.0/20 + 10.2.0.0/20) <-> cicd (172.16.0.0/20 + 172.17.0.0/20)
# app route tables lose 172.16.0.0/20 and 172.17.0.0/20, keep 192.168.0.0/20
# cicd route tables lose 10.0.0.0/20, 10.1.0.0/20, 10.2.0.0/20, keep 192.168.0.0/20
# general is unaffected (gets all app + cicd cidrs)
output "ipv4_with_secondary_cidrs_deny_app_to_cicd" {
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
      route_table_id         = "rtb-0094331bdafb627f3"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-01e2b1283c7404903"
    },
    {
      destination_cidr_block = "192.168.0.0/20"
      route_table_id         = "rtb-0c92ed73f355dcc65"
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

# deny all pairs: app <-> cicd AND app <-> general AND cicd <-> general
# every VPC is denied from every other = no routes at all
output "ipv4_deny_all_pairs" {
  value = toset([])
}
