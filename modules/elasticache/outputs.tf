# modules/elasticache/outputs.tf

output "replication_group_id" {
  description = "Redis Replication Group ID"
  value       = aws_elasticache_replication_group.this.id
}

output "primary_endpoint" {
  description = "Redis Primary Endpoint"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint" {
  description = "Redis Reader Endpoint"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "port" {
  description = "Redis Port"
  value       = aws_elasticache_replication_group.this.port
}

output "secret_arn" {
  description = "Secrets Manager Secret ARN containing the auth token"
  value       = aws_secretsmanager_secret.redis_credentials.arn
}