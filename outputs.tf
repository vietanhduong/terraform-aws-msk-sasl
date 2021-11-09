output "proxy_private_key" {
  description = "Proxy RSA Private key"
  value       = tls_private_key.proxy.private_key_pem
  sensitive   = true
}

output "proxy_public_ip" {
  description = "Proxy IP address"
  value       = aws_instance.proxy.0.public_ip
}

output "zookeeper_connect_string" {
  description = "MSK Zookeeper connection string"
  value       = aws_msk_cluster.this.zookeeper_connect_string
}

output "bootstrap_brokers_sasl_scram" {
  description = "MSK bootstrap brokers url"
  value       = aws_msk_cluster.this.bootstrap_brokers_sasl_scram
}

output "cluster_arn" {
  description = "MSK Cluster ARN"
  value       = aws_msk_cluster.this.arn
}
