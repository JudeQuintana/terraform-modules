locals {
  cidr_to_segment_name = {
    for pair in flatten([
      for segment_name, vpcs in var.generate_routes_to_other_vpcs.routing_policy.segments : [
        for vpc in vpcs : { cidr = vpc.network_cidr, segment = segment_name }
      ]
    ]) : pair.cidr => pair.segment
  }

  segment_report = {
    for name, vpc in var.generate_routes_to_other_vpcs.vpcs : name => {
      segment = lookup(local.cidr_to_segment_name, vpc.network_cidr, "unsegmented")
      reaches = sort([
        for other_name in keys(var.generate_routes_to_other_vpcs.vpcs) :
        other_name
        if other_name != name
        && lookup(local.reachability_lookup, join(":", sort([name, other_name]))).verdict == "permitted"
      ])
      denied = sort([
        for other_name in keys(var.generate_routes_to_other_vpcs.vpcs) :
        other_name
        if other_name != name
        && lookup(local.reachability_lookup, join(":", sort([name, other_name]))).verdict == "denied"
      ])
    }
  }
}
