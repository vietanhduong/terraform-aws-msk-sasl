## Setup provider
provider "aws" {
  region = "ap-southeast-1"
}

## Setup network
### Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

### Get AZs
data "aws_availability_zones" "available" {
  state = "available"
}

### Create subnet per zone
resource "aws_subnet" "subnet" {
  count             = length(data.aws_availability_zones.available.names)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.vpc.id

}


## Init module
module "msk-sasl" {
  source = "vietanhduong/msk-sasl/aws"

  cluster_name       = "msk"
  vpc_id             = aws_vpc.vpc.id
  kafka_version      = "2.6.2"
  broker_type        = "kafka.t3.small"
  broker_volume_size = 512
  broker_count       = 2
  enable_cloudwatch  = true
  enable_proxy       = true
  proxy_whitelist_ip = ["0.0.0.0/0"]
  sasl_username      = "<sensitive_value>"
  sasl_password      = "<sensitive_value>"
  cluster_config = [
    "auto.create.topics.enable = true",
    "delete.topic.enable = true"
  ]

  depends_on = [aws_subnet.subnet]
}
