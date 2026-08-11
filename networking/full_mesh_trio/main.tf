/*
* # Full Mesh Trio
*
* Cross-region full mesh between three Centralized Routers. Builds TGW peering
* attachments and static routes across all three TGWs, then compiles an optional
* routing policy (deny > allow > segments > default) into cross-region VPC route
* table entries. Operates as the Global IR, evaluating policy across all regions
* in a single declaration.
*
* `v1.10.0`:
* - Breaking change: cross-region VPC routes now use policy compilation instead of VPC aggregate setproduct.
* - Route resource names are consolidated and renamed.
* - New `routing_policy` variable with four primitives and fixed precedence: deny > allow > segments > default.
* - Dual-stack support: one policy declaration controls both IPv4 and IPv6 route generation.
* - Scope-invariant: same policy evaluation as Centralized Router and Super Router.
* - Uses `generate_routes_to_other_vpcs` v1.10.0 as the shared compilation unit.
*
* `v1.9.0`:
* - reorganize files
* - ipv4 VPC routes for ipv4 secondary cidrs
* - ipv4 TGW routes for ipv4 secondary cidrs
* - ipv6 VPC routes for ipv6 network cidrs
* - ipv6 TGW routes for ipv6 network cidrs
* - ipv6 VPC routes for ipv6 secondary cidrs
* - ipv6 TGW routes for ipv6 secondary cidrs
* - moar validation
* ```
* module "full_mesh_trio" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/full_mesh_trio?ref=v1.9.0"
* ...
* ```
*
*
* `v1.7.5`:
* - ipv4 VPC routes for ipv4 network cidrs
* ```
* module "full_mesh_trio" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/full_mesh_trio?ref=v1.7.5"
*
*   providers = {
*     aws.one   = aws.use1
*     aws.two   = aws.use2
*     aws.three = aws.usw2
*   }
*
*  env_prefix = var.env_prefix
*  full_mesh_trio = {
*    one = {
*      centralized_router = module.centralized_router_use1
*    }
*    two = {
*      centralized_router = module.centralized_router_use2
*    }
*    three = {
*      centralized_router = module.centralized_router_usw2
*    }
*  }
* }
*
* output "full_mesh_trio" {
*  value = module.full_mesh_trio
* }
* ```
*/
