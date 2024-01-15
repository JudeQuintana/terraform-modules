/*
* # Mega Mesh
*
* ```
* module "mega_mesh" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/mega-mesh?ref=mega-mesh"
*
*   providers = {
*     aws.one   = aws.use1
*     aws.two   = aws.use2
*     aws.three = aws.usw2
*     aws.four  = aws.usw1
*   }
*
*  env_prefix = var.env_prefix
*  mega_mesh = {
*    one = {
*      centralized_router = module.centralized_router_use1
*    }
*    two = {
*      centralized_router = module.centralized_router_use2
*    }
*    three = {
*      centralized_router = module.centralized_router_usw2
*    }
*    four = {
*      centralized_router = module.centralized_router_usw1
*    }
*  }
* }
*
* output "mega_mesh" {
*  value = module.mega_mesh
* }
* ```
*/
