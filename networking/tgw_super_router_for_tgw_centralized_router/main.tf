/*
* # Super Router Description
* This is a follow up to the [generating routes post](https://jq1.io/posts/generating_routes/).
*
* Original Blog Post: [Super Powered, Super Sharp, Super Router!](https://jq1.io/posts/super_router/)
*
* See the new [$init super refactor](https://jq1.io/posts/init_super_refactor/) blog post for moar deets on the refactor!
*
* [Super Router Demo](https://github.com/JudeQuintana/terraform-main/tree/main/super_router_demo)
*
* Super Router provides both intra-region and cross-region peering and routing for Centralized Routers and Tiered VPCs (same AWS account only, no cross account).
*
* Super Router is composed of two TGWs instead of one TGW (one for each region).
*
* Example:
* ```
* module "super_router_usw2_to_use1" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/tgw_super_router_for_tgw_centralized_router?ref=moar-better"
*
*   providers = {
*     aws.local = aws.usw2 # local super router tgw will be built in the aws.local provider region
*     aws.peer  = aws.use1 # peer super router tgw will be built in the aws.peer provider region
*   }
*
*   env_prefix       = var.env_prefix
*   region_az_labels = var.region_az_labels
*   super_router = {
*     name = "professor-x"
*     local = {
*       amazon_side_asn     = 64521
*       centralized_routers = module.centralized_routers_usw2
*     }
*     peer = {
*       amazon_side_asn     = 64522
*       centralized_routers = module.centralized_routers_use1
*     }
*   }
* }
*
*```
*
* ![super-router](https://jq1.io/img/super-refactor-after.png)
*/
