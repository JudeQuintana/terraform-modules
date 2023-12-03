/*
* # Full Mesh Intra VPC Secuity Group Rules Description
* - This allowing inbound protocols across regions based on rules (ie ssh, icmp, etc) that
*   were used in each intra\_vpc\_security\_group\_rules modules for all vpcs in each region.
* - Rule sets for one, two and three Intra VPC Security Group Rules should be the same. also enforced by validation
* - See it in action in [security\_group\_rules.tf](https://github.com/JudeQuintana/terraform-main/blob/full-mesh-intra-vpc-security-rules/full_mesh_trio_demo/security_group_rules.tf) in the [Full Mesh Trio Demo](https://github.com/JudeQuintana/terraform-main/tree/full-mesh-intra-vpc-security-rules/full_mesh_trio_demo).
*
* ```
* module "full_mesh_intra_vpc_security_groups_rules" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/full_mesh_intra_vpc_security_group_rules?ref=v1.7.0"
*
*   providers = {
*     aws.one   = aws.use1
*     aws.two   = aws.use2
*     aws.three = aws.usw2
*   }
*
*   env_prefix       = var.env_prefix
*   region_az_labels = var.region_az_labels
*   full_mesh_intra_vpc_security_group_rules = {
*     one = {
*       intra_vpc_security_group_rules = module.intra_vpc_security_group_rules_use1
*     }
*     two = {
*       intra_vpc_security_group_rules = module.intra_vpc_security_group_rules_use2
*     }
*     three = {
*       intra_vpc_security_group_rules = module.intra_vpc_security_group_rules_usw2
*     }
*   }
* }
* ```
*
*/

