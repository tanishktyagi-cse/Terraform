output "Instance-ip" {
  value = aws_eip.grafana_eip.public_ip
}
