output "broker_private_ips" {
  description = "Kafka 브로커들의 내부 IP 목록"
  value = concat(
    aws_instance.broker_zone_a[*].private_ip,
    aws_instance.broker_zone_c[*].private_ip
  )
}
