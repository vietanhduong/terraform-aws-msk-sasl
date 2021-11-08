locals {
  subnet_per_zone = { for s in data.aws_subnet.selected : s.availability_zone => s.id... }
  subnet_ids      = [for _, s in local.subnet_per_zone : s[0]]
  public_subnets  = [for s in data.aws_subnet.selected : s.id if s.map_public_ip_on_launch]
}
