output "proxy_private_key" {
  value     = tls_private_key.proxy.private_key_pem
  sensitive = true
}

output "proxy_public_ip" {
  value = aws_instance.proxy.0.public_ip
}
