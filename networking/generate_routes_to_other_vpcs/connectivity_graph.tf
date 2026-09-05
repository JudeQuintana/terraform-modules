locals {
  connectivity_graph_verdict_color = {
    "allow"   = "#3498db"
    "segment" = "#2ecc71"
    "default" = "#95a5a6"
  }

  connectivity_graph_segment_subgraphs = [
    for segment_name, vpcs in var.generate_routes_to_other_vpcs.routing_policy.segments :
    join("\n", concat(
      [format("  subgraph cluster_%s {", replace(replace(segment_name, "-", "_"), " ", "_"))],
      [format("    label=\"%s\"", segment_name)],
      ["    style=dashed"],
      ["    color=\"#95a5a6\""],
      [for vpc in vpcs : format("    \"%s\"", lookup(local.cidr_to_vpc_name, vpc.network_cidr, vpc.network_cidr))],
      ["  }"]
    ))
  ]

  connectivity_graph_unsegmented_nodes = [
    for name, vpc in var.generate_routes_to_other_vpcs.vpcs :
    format("  \"%s\"", name)
    if lookup(local.cidr_to_segment_name, vpc.network_cidr, null) == null
  ]

  connectivity_graph_edges = [
    for pair, verdict in local.reachability :
    format("  \"%s\" -- \"%s\" [color=\"%s\", label=\"%s\"]",
      element(split(":", pair), 0),
      element(split(":", pair), 1),
      lookup(local.connectivity_graph_verdict_color, element(split(":", verdict), 1), "#95a5a6"),
      element(split(":", verdict), 1)
    )
    if startswith(verdict, "permitted")
  ]

  connectivity_graph = join("\n", concat(
    ["graph connectivity {"],
    ["  graph [rankdir=LR]"],
    ["  node [shape=box, style=filled, fillcolor=\"#f0f0f0\"]"],
    ["  edge [fontsize=10]"],
    [""],
    local.connectivity_graph_segment_subgraphs,
    local.connectivity_graph_unsegmented_nodes,
    [""],
    local.connectivity_graph_edges,
    ["}"],
    [""]
  ))
}
