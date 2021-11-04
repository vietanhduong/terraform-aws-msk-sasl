data "aws_vpc" "selected" {
  default = var.vpc_id == ""
  id      = var.vpc_id == "" ? null : var.vpc_id
}

data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id
}

data "aws_subnet" "selected" {
  for_each = data.aws_subnet_ids.selected.ids
  id       = each.value
}
