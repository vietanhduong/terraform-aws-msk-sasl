## Setup provider
provider "aws" {
  region = "ap-southeast-1"
}

## Init module
module "msk-sasl" {
  source = "vietanhduong/msk-sasl/aws"

  cluster_name       = "msk"
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

}
