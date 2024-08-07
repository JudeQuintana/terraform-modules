/*
* # Intra VPC Security Group Rule Description
* This Intra VPC Security Group Rule will create a SG Rule for each Tiered VPC allowing inbound-only ports from all other VPC networks (excluding itself).
*
* `v1.8.2`
* - New [Dual Stack Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/dual_stack_networking_trifecta_demo)
* - Same declaration as before but now supports VPC IPv4 Secondary CIDRs
*
* `v1.8.2` example:
* ```
* module "intra_vpc_security_group_rules" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/intra_vpc_security_group_rule_for_tiered_vpc_ng?ref=v1.8.2"
*
*   for_each = { for r in local.intra_vpc_security_group_rules : r.label => r }
*
*   env_prefix       = var.env_prefix
*   region_az_labels = var.region_az_labels
*   intra_vpc_security_group_rule = {
*     rule = each.value
*     vpcs = module.vpcs
*   }
* }
* ```
*
* `v1.8.1`:
* - Creates SG rules for IPv4 VPC network cidrs across VPCs
* - Allowing SSH and ping communication across VPCs
*
* `v1.8.1` example:
* ```
* # This will create a sg rule for each vpc allowing inbound-only ports from all other vpc networks (excluding itself).
* # Basically allowing ssh and ping communication across all VPCs.
* locals {
*   intra_vpc_security_group_rules = [
*     {
*       label     = "ssh"
*       protocol  = "tcp"
*       from_port = 22
*       to_port   = 22
*     },
*     {
*       label     = "ping"
*       protocol  = "icmp"
*       from_port = 8
*       to_port   = 0
*     }
*   ]
* }
*
* module "intra_vpc_security_group_rules" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/intra_vpc_security_group_rule_for_tiered_vpc_ng?ref=v1.8.1"
*
*   for_each = { for r in local.intra_vpc_security_group_rules : r.label => r }
*
*   env_prefix       = var.env_prefix
*   region_az_labels = var.region_az_labels
*   intra_vpc_security_group_rule = {
*     rule = each.value
*     vpcs = module.vpcs
*   }
* }
* ```
*
* # Networking Trifecta Demo
* Blog Post:
* [Terraform Networking Trifecta ](https://jq1.io/posts/tnt/)
*
* Main:
* - [Networking Trifecta Demo](https://github.com/JudeQuintana/terraform-main/tree/main/networking_trifecta_demo)
*   - See [Trifecta Demo Time](https://jq1.io/posts/tnt/#trifecta-demo-time) for instructions.
*
*/
