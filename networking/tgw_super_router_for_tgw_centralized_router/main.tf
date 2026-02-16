/*
* # Super Router Description
* v1.9.6 (v1.0.1):
* Super Router now fully interprets AWS TGW network intent across address space, topology, and egress semantics, with no special cases.
*
* What's new
* - Full support for IPv4 and IPv6, including primary and secondary CIDRs
* - Ability to define blackhole CIDRs on either side of Super Router
* - Operates on semantic facts (CIDRs × route table identities) rather than emitted route artifacts
* - Compatible with Centralized Router v1.0.6
*
* Semantic Coverage
*
* Super Router now provides complete semantic coverage of the AWS TGW routing domain:
* - Expressive: handles all CIDR and address-family combinations
* - Compositional: hierarchical domains compose cleanly
* - Complete: covers the full AWS TGW routing semantic space
*
* Example:
* ```
* # Super Router is composed of two TGWs, one in each region.
* module "super_router_usw2_to_use1" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/tgw_super_router_for_tgw_centralized_router?ref=v1.9.6"
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
*       blackhole           = local.blackhole
*       centralized_routers = module.centralized_routers_usw2
*     }
*     peer = {
*       amazon_side_asn     = 64522
*       blackhole           = local.blackhole
*       centralized_routers = module.centralized_routers_use1
*     }
*   }
* }
* ```
*
* v1.7.5 (v1.0.0):
* This is a follow up to the [generating routes post](https://jq1.io/posts/generating_routes/).
*
* Original Blog Post: [Super Powered, Super Sharp, Super Router!](https://jq1.io/posts/super_router/)
*
* Fresh new decentralized design in [$init super refactor](https://jq1.io/posts/init_super_refactor/).
*
* New features means new steez in [Slappin chrome on the WIP'](https://jq1.io/posts/slappin_chrome_on_the_wip/)!
*
* Super Router provides both intra-region and cross-region peering and routing for Centralized Routers and Tiered VPCs (same AWS account only, no cross account).
*
* Super Router is composed of two TGWs instead of one TGW (one for each region).
*
* Example:
* ```
* module "super_router_usw2_to_use1" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/tgw_super_router_for_tgw_centralized_router?ref=v1.7.5"
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
* ```
*
* The resulting architecture is a decentralized hub spoke topology:
* ![super-router-shokunin](https://jq1-io.s3.amazonaws.com/super-router/super-router-shokunin.png)
*/
