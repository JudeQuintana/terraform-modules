/*
* # Super Intra VPC Secuity Group Rules Description
* - This allowing inbound protocols across regions based on rules (ie ssh, icmp, etc) that
*   were used in each intra_vpc_security_group_rules modules for all vpcs in each region.
* - Rule sets for local and peer should be the same. also enforce by validation
*
* - See [security_group_rules.tf](https://github.com/JudeQuintana/terraform-main/blob/main/super_router_demo/security_group_rules.tf) in the [Super Router Demo](https://github.com/JudeQuintana/terraform-main/tree/main/super_router_demo).
*
* Example:
* ```
* module "super_intra_vpc_security_group_rules_usw2_to_use1" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/super_intra_vpc_security_group_rules?ref=v1.4.9"
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
