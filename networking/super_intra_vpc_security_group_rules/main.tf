/*
* # Super Intra VPC Secuity Group Rules Description
* - This allowing inbound protocols for IPv4 CIDRs across regions based on rules (ie ssh, icmp, etc) that
*   were used in each intra_vpc_security_group_rules modules for all vpcs in each region.
* - Rule sets for local and peer should be the same. also enforce by validation
*
* v1.9.6 (v1.0.1):
* - Support for IPv4 secondaries.
* - See [security_group_rules.tf](https://github.com/JudeQuintana/terraform-main/blob/main/super_router_revamped_demo/security_group_rules.tf) in the [Super Router Revamped Demo](https://github.com/JudeQuintana/terraform-main/tree/main/super_router_revamped_demo).
*
* Example (same as before except the source change):
* ```
* module "super_intra_vpc_security_group_rules_usw2_to_use1" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/super_intra_vpc_security_group_rules?ref=v1.9.6"
*
*   providers = {
*     aws.local = aws.usw2
*     aws.peer  = aws.use1
*   }
*
*   env_prefix       = var.env_prefix
*   region_az_labels = var.region_az_labels
*   super_intra_vpc_security_group_rules = {
*     local = {
*       intra_vpc_security_group_rules = module.intra_vpc_security_group_rules_usw2
*     }
*     peer = {
*       intra_vpc_security_group_rules = module.intra_vpc_security_group_rules_use1
*     }
*   }
* }
* ```
*
* v1.7.5 (v1.0.0):
* - See [security_group_rules.tf](https://github.com/JudeQuintana/terraform-main/blob/main/super_router_demo/security_group_rules.tf) in the [Super Router Demo](https://github.com/JudeQuintana/terraform-main/tree/main/super_router_demo).
*
* Example:
* ```
* module "super_intra_vpc_security_group_rules_usw2_to_use1" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/super_intra_vpc_security_group_rules?ref=v1.7.5"
*
*   providers = {
*     aws.local = aws.usw2
*     aws.peer  = aws.use1
*   }
*
*   env_prefix       = var.env_prefix
*   region_az_labels = var.region_az_labels
*   super_intra_vpc_security_group_rules = {
*     local = {
*       intra_vpc_security_group_rules = module.intra_vpc_security_group_rules_usw2
*     }
*     peer = {
*       intra_vpc_security_group_rules = module.intra_vpc_security_group_rules_use1
*     }
*   }
* }
* ```
*
*/
