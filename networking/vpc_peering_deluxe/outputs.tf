output "peering" {
  value = {
    allow_remote_vpc_dns_resolution = var.vpc_peering_deluxe.allow_remote_vpc_dns_resolution
    connection_id                   = aws_vpc_peering_connection_accepter.this_local_to_this_peer.id
    from_local                      = var.vpc_peering_deluxe.local.vpc.full_name
    to_peer                         = var.vpc_peering_deluxe.peer.vpc.full_name
  }
}

#output routes?
