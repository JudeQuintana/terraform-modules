/*
* # Generate Routes to Other VPCs
*
* Scope-agnostic route compilation unit that evaluates a routing policy
* (deny > allow > segments > default) to generate IPv4 and IPv6 VPC route objects.
*
* This is a function-type module (no resources). It takes a map of Tiered VPC-NG objects
* and an optional `routing_policy`, then emits filtered route sets consumed by route resources
* in Centralized Router (Regional IR), Full Mesh Trio (Global IR), and Super Router (Domain IR).
*
* Run the test suites with `terraform test` in the top level directory in the repo.
* ```
* ```
* tests/deny_policy.tftest.hcl... in progress
*   run "setup"... pass
*   run "final_deny"... pass
*   run "ipv4_deny_app_to_cicd"... pass
*   run "ipv4_with_secondary_cidrs_deny_app_to_cicd"... pass
*   run "ipv4_deny_all_pairs"... pass
*   run "ipv4_with_secondary_cidrs_deny_all_pairs"... pass
*   run "final"... pass
*   run "ipv4_empty_deny_unchanged"... pass
*   run "ipv4_default_policy_unchanged"... pass
*   run "ipv6_deny_app_to_cicd"... pass
*   run "ipv6_with_secondary_cidrs_deny_app_to_cicd"... pass
*   run "ipv6_deny_all_pairs"... pass
*   run "ipv6_empty_deny_unchanged"... pass
*   run "ipv6_default_policy_unchanged"... pass
* tests/deny_policy.tftest.hcl... tearing down
* tests/deny_policy.tftest.hcl... pass
* tests/generate_routes.tftest.hcl... in progress
*   run "setup"... pass
*   run "final"... pass
*   run "ipv4_call_with_n_greater_than_one"... pass
*   run "ipv4_call_with_n_equal_to_one"... pass
*   run "ipv4_call_with_n_equal_to_zero"... pass
*   run "ipv4_cidr_validation"... pass
*   run "ipv4_with_secondary_cidrs_call_with_n_greater_than_one"... pass
*   run "ipv4_with_secondary_cidrs_call_with_n_equal_to_one"... pass
*   run "ipv4_with_secondary_cidrs_call_with_n_equal_to_zero"... pass
*   run "ipv6_call_with_n_greater_than_one"... pass
*   run "ipv6_call_with_n_equal_to_one"... pass
*   run "ipv6_call_with_n_equal_to_zero"... pass
*   run "ipv6_call_with_ipv6_secondary_cidrs_with_n_greater_than_zero"... pass
*   run "ipv6_with_secondary_cidrs_call_with_n_equal_to_one"... pass
*   run "ipv6_with_ipv6_secondary_cidrs_call_with_n_equal_to_zero"... pass
* tests/generate_routes.tftest.hcl... tearing down
* tests/generate_routes.tftest.hcl... pass
* tests/precedence_policy.tftest.hcl... in progress
*   run "setup"... pass
*   run "final_precedence"... pass
*   run "final_deny"... pass
*   run "final"... pass
*   run "ipv4_default_deny_no_rules"... pass
*   run "ipv4_default_deny_allow_app_cicd"... pass
*   run "ipv4_default_deny_segment_workers"... pass
*   run "ipv4_deny_beats_allow"... pass
*   run "ipv4_allow_overrides_segments"... pass
*   run "ipv4_with_secondary_cidrs_default_deny_allow_app_cicd"... pass
*   run "ipv4_with_secondary_cidrs_default_deny_segment_workers"... pass
*   run "ipv4_with_secondary_cidrs_deny_beats_allow"... pass
*   run "ipv4_with_secondary_cidrs_allow_overrides_segments"... pass
*   run "ipv4_combined_precedence"... pass
*   run "ipv4_with_secondary_cidrs_combined_precedence"... pass
*   run "ipv4_default_allow_empty_policy"... pass
*   run "ipv6_default_deny_no_rules"... pass
*   run "ipv6_default_deny_allow_app_cicd"... pass
*   run "ipv6_default_deny_segment_workers"... pass
*   run "ipv6_deny_beats_allow"... pass
*   run "ipv6_allow_overrides_segments"... pass
*   run "ipv6_combined_precedence"... pass
*   run "ipv6_default_allow_empty_policy"... pass
* tests/precedence_policy.tftest.hcl... tearing down
* tests/precedence_policy.tftest.hcl... pass
* tests/segments_policy.tftest.hcl... in progress
*   run "setup"... pass
*   run "final_segments"... pass
*   run "final"... pass
*   run "ipv4_one_segment_general_unsegmented"... pass
*   run "ipv4_two_segments_general_unsegmented"... pass
*   run "ipv4_all_separate_segments"... pass
*   run "ipv4_with_secondary_cidrs_two_segments_general_unsegmented"... pass
*   run "ipv4_with_secondary_cidrs_all_separate_segments"... pass
*   run "ipv4_empty_segments_unchanged"... pass
*   run "ipv4_vpc_in_multiple_segments"... pass
*   run "ipv6_two_segments_general_unsegmented"... pass
*   run "ipv6_all_separate_segments"... pass
*   run "ipv6_with_secondary_cidrs_two_segments_general_unsegmented"... pass
*   run "ipv6_empty_segments_unchanged"... pass
* tests/segments_policy.tftest.hcl... tearing down
* tests/segments_policy.tftest.hcl... pass
*
* Success! 66 passed, 0 failed.
*  The test suite will help when refactoring is needed.
*
* `v1.10.0`
* - Routing policy language integration.
* - Policy algebra with four primitives and fixed precedence: deny > allow > segments > default.
* - Dual-stack support: one policy declaration controls both IPv4 and IPv6 route generation.
* - Scope-invariant: same evaluation across Regional IR (Centralized Router), Global IR (Full Mesh Trio), and Domain IR (Super Router).
* - 51 new policy tests (deny, segments, precedence) added to existing 15 route generation tests.
* - See [docs/routing-policy-language.md](docs/routing-policy-language.md) for full specification.
*
* `v1.9.0`
* - supportes generating VPC routes for IPv6 secondary cidrs across vpcs.
*
* `v1.8.2`
* - now supports generating VPC routes IPv4 Secondary cidrs and IPv6 cidrs across vpcs.
*
* `v1.8.1`
* This is a function type module (no resources) that will take a map of `tiered_vpc_ng` objects with [Tiered VPC-NG](https://github.com/JudeQuintana/terraform-modules/tree/master/networking/tiered_vpc_ng).
*
* It will create a map of routes to other VPC networks (execept itself) which will then be consumed by route resources.
*
* The `call` output is `toset([{ route_table_id = "rtb-12345678", destination_cidr_block = "x.x.x.x/x" }, ...])`.
*
* A list of route objects makes it easier to handle when passing to other route resource types (ie vpc, tgw) than a map of routes.
*
* ```hcl
* # snippet
* module "generate_routes_to_other_vpcs" {
*  source = "git@github.com:JudeQuintana/terraform-modules.git//networking/generate_routes_to_other_vpcs?ref=v1.8.1"
*
*   vpcs = var.vpcs
* }
*
* locals {
*   vpc_routes_to_other_vpcs = {
*     for this in module.generate_routes_to_other_vpcs.call :
*     format("|", this.route_table_id, this.destination_cidr_block) => this
*   }
* }
*
* resource "aws_route" "this" {
*   for_each = local.vpc_routes_to_other_vpcs
*
*   destination_cidr_block = each.value.destination_cidr_block
*   route_table_id         = each.value.route_table_id
*   transit_gateway_id     = aws_ec2_transit_gateway.this.id
*
*   # make sure the tgw route table is available first before the setting routes routes on the vpcs
*   depends_on = [aws_ec2_transit_gateway_route_table.this]
* }
* ```
*
*/
