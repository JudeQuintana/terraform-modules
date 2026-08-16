# default=deny, allow app <-> cicd only
# app route tables get 172.16.0.0/20, cicd route tables get 10.0.0.0/20
# general gets nothing, no one gets general
output "ipv4_default_deny_allow_app_cicd" {
  value = toset([
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
      route_table_id         = "rtb-0b0b9d1c342f155a9"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-026bb809ef2dcbf02"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0bdbabf9e8e133fa8"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0e36393dc78c51235"
    },
  ])
}

# default=deny, segments: app and cicd in "workers", general unsegmented
# app <-> cicd: same segment, routes exist
# general: unsegmented, but default=deny so unsegmented <-> unsegmented only
# general has no other unsegmented VPCs to reach, so general gets nothing
# app/cicd don't reach general (general is unsegmented but they are segmented, cross-boundary)
# wait — unsegmented VPCs are not segment-denied from anyone. segment_deny only applies between segments.
# but default=deny means: if no other rule permits, deny.
# for segmented VPC reaching unsegmented VPC: not in deny, not in allow, not segment-denied (segment_deny only between segments)
# so falls through to default=deny -> blocked.
# Result: only app <-> cicd
output "ipv4_default_deny_segment_workers" {
  value = toset([
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
      route_table_id         = "rtb-0b0b9d1c342f155a9"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-026bb809ef2dcbf02"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0bdbabf9e8e133fa8"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0e36393dc78c51235"
    },
  ])
}

# default=deny with secondary cidrs, allow app <-> cicd only
# app route tables get 172.16.0.0/20 + 172.17.0.0/20, cicd route tables get 10.0.0.0/20 + 10.1.0.0/20 + 10.2.0.0/20
# general gets nothing, no one gets general
output "ipv4_with_secondary_cidrs_default_deny_allow_app_cicd" {
  value = toset([
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-04c6baa3a6a0af91e"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-06836f9bc939ebbce"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-0c92ed73f355dcc65"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-04c6baa3a6a0af91e"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-06836f9bc939ebbce"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-0c92ed73f355dcc65"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0094331bdafb627f3"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-01e2b1283c7404903"
    },
    {
      destination_cidr_block = "10.1.0.0/20"
      route_table_id         = "rtb-0094331bdafb627f3"
    },
    {
      destination_cidr_block = "10.1.0.0/20"
      route_table_id         = "rtb-01e2b1283c7404903"
    },
    {
      destination_cidr_block = "10.2.0.0/20"
      route_table_id         = "rtb-0094331bdafb627f3"
    },
    {
      destination_cidr_block = "10.2.0.0/20"
      route_table_id         = "rtb-01e2b1283c7404903"
    },
  ])
}

# default=deny with secondary cidrs, segment "workers" [app, cicd]
# app <-> cicd same segment = routes exist (including all secondaries)
# general is unsegmented, falls through to default=deny = no routes
output "ipv4_with_secondary_cidrs_default_deny_segment_workers" {
  value = toset([
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-04c6baa3a6a0af91e"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-06836f9bc939ebbce"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-0c92ed73f355dcc65"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-04c6baa3a6a0af91e"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-06836f9bc939ebbce"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-0c92ed73f355dcc65"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0094331bdafb627f3"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-01e2b1283c7404903"
    },
    {
      destination_cidr_block = "10.1.0.0/20"
      route_table_id         = "rtb-0094331bdafb627f3"
    },
    {
      destination_cidr_block = "10.1.0.0/20"
      route_table_id         = "rtb-01e2b1283c7404903"
    },
    {
      destination_cidr_block = "10.2.0.0/20"
      route_table_id         = "rtb-0094331bdafb627f3"
    },
    {
      destination_cidr_block = "10.2.0.0/20"
      route_table_id         = "rtb-01e2b1283c7404903"
    },
  ])
}

# allow overrides segments with secondary cidrs: app in "alpha", cicd in "beta" (cross-segment denied),
# but allow app <-> cicd punches through (all cidrs including secondaries)
# general unsegmented, default=allow, so general routes to all
output "ipv4_with_secondary_cidrs_allow_overrides_segments" {
  value = toset([
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-04c6baa3a6a0af91e"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-06836f9bc939ebbce"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-0c92ed73f355dcc65"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-04c6baa3a6a0af91e"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-06836f9bc939ebbce"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-0c92ed73f355dcc65"
    },
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
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0094331bdafb627f3"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-01e2b1283c7404903"
    },
    {
      destination_cidr_block = "10.1.0.0/20"
      route_table_id         = "rtb-0094331bdafb627f3"
    },
    {
      destination_cidr_block = "10.1.0.0/20"
      route_table_id         = "rtb-01e2b1283c7404903"
    },
    {
      destination_cidr_block = "10.2.0.0/20"
      route_table_id         = "rtb-0094331bdafb627f3"
    },
    {
      destination_cidr_block = "10.2.0.0/20"
      route_table_id         = "rtb-01e2b1283c7404903"
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

# combined precedence: deny=[app<->general], allow=[app<->cicd], segments={alpha=[app], beta=[cicd]}, default=allow
# app -> cicd: allowed (allow overrides cross-segment deny)
# app -> general: denied (explicit deny, highest precedence)
# cicd -> general: allowed (default=allow, no segment_deny between segmented and unsegmented)
# general -> cicd: allowed (default=allow, unsegmented)
# general -> app: denied (explicit deny)
output "ipv4_combined_precedence" {
  value = toset([
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
      route_table_id         = "rtb-0b0b9d1c342f155a9"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-026bb809ef2dcbf02"
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

# combined precedence with secondary cidrs: deny=[app<->general], allow=[app<->cicd], segments={alpha=[app], beta=[cicd]}, default=allow
# app -> cicd: allowed (all cidrs including secondaries)
# app -> general: denied (explicit deny blocks all cidrs)
# cicd -> general: allowed (default=allow, general unsegmented)
# general -> cicd: allowed (default=allow, general unsegmented)
# general -> app: denied (explicit deny blocks all cidrs)
output "ipv4_with_secondary_cidrs_combined_precedence" {
  value = toset([
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-04c6baa3a6a0af91e"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-06836f9bc939ebbce"
    },
    {
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-0c92ed73f355dcc65"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-04c6baa3a6a0af91e"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-06836f9bc939ebbce"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-0c92ed73f355dcc65"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-0094331bdafb627f3"
    },
    {
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-01e2b1283c7404903"
    },
    {
      destination_cidr_block = "10.1.0.0/20"
      route_table_id         = "rtb-0094331bdafb627f3"
    },
    {
      destination_cidr_block = "10.1.0.0/20"
      route_table_id         = "rtb-01e2b1283c7404903"
    },
    {
      destination_cidr_block = "10.2.0.0/20"
      route_table_id         = "rtb-0094331bdafb627f3"
    },
    {
      destination_cidr_block = "10.2.0.0/20"
      route_table_id         = "rtb-01e2b1283c7404903"
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
      destination_cidr_block = "172.16.0.0/20"
      route_table_id         = "rtb-066adc27add9a630e"
    },
    {
      destination_cidr_block = "172.17.0.0/20"
      route_table_id         = "rtb-066adc27add9a630e"
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

# allow overrides segments: app in "alpha", cicd in "beta" (cross-segment denied),
# but allow app <-> cicd punches through
# general unsegmented, default=allow, so general routes to all
output "ipv4_allow_overrides_segments" {
  value = toset([
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
      route_table_id         = "rtb-0b0b9d1c342f155a9"
    },
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
      destination_cidr_block = "10.0.0.0/20"
      route_table_id         = "rtb-026bb809ef2dcbf02"
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
