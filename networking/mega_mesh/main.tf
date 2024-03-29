/*
* # Mega Mesh
* Mega Mesh == (Full Mesh Trio)² + 1
* Full Mesh Transit Gateway across 10 regions.
* [Demo](https://github.com/JudeQuintana/terraform-main/tree/main/mega_mesh_demo)
*
* ![mega-mesh](https://jq1-io.s3.amazonaws.com/mega-mesh/ten-full-mesh-tgw.png)
*
* ```
* module "mega_mesh" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/mega_mesh?ref=v1.8.0"
*
*   providers = {
*     aws.one   = aws.use1
*     aws.two   = aws.usw1
*     aws.three = aws.euc1
*     aws.four  = aws.euw1
*     aws.five  = aws.apne1
*     aws.six   = aws.apse1
*     aws.seven = aws.cac1
*     aws.eight = aws.sae1
*     aws.nine  = aws.use2
*     aws.ten   = aws.usw2
*   }
*
*   env_prefix = var.env_prefix
*   mega_mesh = {
*     one = {
*       centralized_router = module.centralized_router_use1
*     }
*     two = {
*       centralized_router = module.centralized_router_usw1
*     }
*     three = {
*       centralized_router = module.centralized_router_euc1
*     }
*     four = {
*       centralized_router = module.centralized_router_euw1
*     }
*     five = {
*       centralized_router = module.centralized_router_apne1
*     }
*     six = {
*       centralized_router = module.centralized_router_apse1
*     }
*     seven = {
*       centralized_router = module.centralized_router_cac1
*     }
*     eight = {
*       centralized_router = module.centralized_router_sae1
*     }
*     nine = {
*       centralized_router = module.centralized_router_use2
*     }
*     ten = {
*       centralized_router = module.centralized_router_usw2
*     }
*   }
* }
*
* output "mega_mesh" {
*  value = module.mega_mesh
* }
* ```
*/
