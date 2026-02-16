locals {
  upper_env_prefix = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)

  super_router_name = format("%s-%s", local.upper_env_prefix, "super-router")
  route_format      = "%s|%s"
}
