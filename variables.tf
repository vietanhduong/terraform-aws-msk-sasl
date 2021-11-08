variable "region" {
  description = "AWS Region. Default: ap-southeast-1"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_id" {
  description = "VPC to which the MSK will be attached. Default is default VPC in the region"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "MSK Cluster name. Make sure the cluster name is NOT exist"
  type        = string
}

variable "kafka_version" {
  description = "Kafka version. Default is 2.6.2"
  type        = string
  default     = "2.6.2"
}

variable "broker_type" {
  description = "MSK Brokers machine type. Default: kafka.m5.large"
  type        = string
  default     = "kafka.m5.large"
}

variable "broker_volume_size" {
  description = "MSK Broker volume size (GiB). Default: 512"
  type        = number
  default     = 512
}

variable "broker_count" {
  description = "MSK number of broker per zone. E.g: Your VPC in 3 AZ and broker_count is 2 then you will have 6 brokers (with 2 broker/zone)"
  type        = number
  default     = 1
}

variable "enable_cloudwatch" {
  description = "Enable Cloudwatch for logging"
  type        = bool
  default     = false
}

variable "enable_proxy" {
  description = "If this variable is true. This module will create an proxy instance."
  type        = bool
  default     = false
}

variable "proxy_whitelist_ip" {
  description = "Proxy Whitelist IP CIDR Range. Default is 0.0.0.0/0"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "sasl_username" {
  description = "MSK SASL SCRAM username"
  type        = string
  sensitive   = true
}

variable "sasl_password" {
  description = "MSK SASL SCRAM password"
  type        = string
  sensitive   = true
}

variable "cluster_config" {
  description = "MSK configurations"
  type        = list(string)
  default     = []
}
