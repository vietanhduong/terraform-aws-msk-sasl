# Amazon MSK 

**Amazon Managed Streaming for Apache Kafka (Amazon MSK)** is a fully managed service that makes it easy for you to build and run applications that use Apache Kafka to process streaming data.

## Features
* Create MSK Cluster **(Support SASL/SCRAM only)**
* Support proxy

## Usage example

```hcl
provider "aws" {
  region = "ap-southeast-1"
}

module "msk-sasl" {
  source = "vietanhduong/msk-sasl/aws"

  cluster_name       = "msk"
  vpc_id             = "vpc-1234556abcdef"
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
```
