/*
* Full Mesh Trio module builds peering links (red) between existing hub spoke tgws (Centralized Routers) and adds proper routes to all TGWs and their attached VPCs, etc.
*
* The resulting architecture is a full mesh configurion between 3 hub spoke topologies:
* ![full-mesh-trio](https://jq1-io.s3.amazonaws.com/full-mesh-trio/full-mesh-trio.png)
*
* See it in action in the [Full Mesh Trio Demo](https://github.com/JudeQuintana/terraform-main/tree/main/full_mesh_trio_demo)
*
* ```
* module "full_mesh_trio" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/full_mesh_trio?ref=v1.5.0"
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
