locals {
  private_subnets_per_zone = { for s in data.aws_subnet.selected : s.availability_zone => s.id... if !s.map_public_ip_on_launch }
  private_subnet_ids       = [for _, s in local.private_subnets_per_zone : s[0]]
  public_subnets           = [for s in data.aws_subnet.selected : s.id if s.map_public_ip_on_launch]
}
