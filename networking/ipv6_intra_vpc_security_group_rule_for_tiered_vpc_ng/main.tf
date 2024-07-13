/*
* # IPv6 Intra VPC Security Group Rule Description
* This IPv6 Intra VPC Security Group Rule will create a SG Rule for each Tiered VPC allowing inbound-only ports from all other VPC networks (excluding itself).
*
* Allowing IPv6 SSH and ping communication across all VPCs example:
* `v1.8.2`
* - Similar declaration to Intra VPC Security Group Rules modules but this only supports IPv6
* - important to keep IPv6 SG rules as a separate module from IPv4
*
* `v1.8.2` example:
* ```
*
* locals {
*   ipv6_intra_vpc_security_group_rules = [
*     {
*       label     = "ssh6"
*       protocol  = "tcp"
*       from_port = 22
*       to_port   = 22
*     },
*     {
*       label     = "ping6"
*       protocol  = "icmpv6"
*       from_port = -1
*       to_port   = -1
*     }
*   ]
* }
*
* module "ipv6_intra_vpc_security_group_rules" {
*   source = "git@github.com:JudeQuintana/terraform-modules.git//networking/ipv6_intra_vpc_security_group_rule_for_tiered_vpc_ng?ref=1.8.2"
*
*   for_each = { for r in local.ipv6_intra_vpc_security_group_rules : r.label => r }
*
*   env_prefix       = var.env_prefix
*   region_az_labels = var.region_az_labels
*   ipv6_intra_vpc_security_group_rule = {
*     rule = each.value
*     vpcs = module.vpcs
*   }
* }
* ```
*
*/
