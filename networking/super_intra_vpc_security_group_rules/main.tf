/*
* ```
* # allowing ssh and ping communication across regions
* module "super_intra_vpc_security_group_rules_usw2_to_use1" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/super_intra_vpc_security_group_rules?ref=moar-better"
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
