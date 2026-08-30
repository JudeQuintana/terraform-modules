locals {
  full_mesh_trio_name = format("%s-%s-%s", local.upper_env_prefix, "full-mesh-trio", var.full_mesh_trio.name)
  peering_name_format = "%s <-> %s"
  route_format        = "%s|%s"
  upper_env_prefix    = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)
}
