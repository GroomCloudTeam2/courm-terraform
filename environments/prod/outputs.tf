output "api_gateway_url" {
  description = "최종 접속 URL"
  value       = module.api_gateway.api_endpoint
}

output "jenkins_url" {
  description = "젠킨스 접속 URL"
  value       = "http://${module.jenkins.public_ip}:8080"
}

output "rds_endpoints" {
  description = "DB 접속 주소"
  value = {
    product_master = module.rds_product.rds_endpoint
    order_master   = module.rds_order.rds_endpoint
  }
}

output "redis_endpoint" {
  description = "Redis 엔드포인트"
  value       = module.elasticache_redis.primary_endpoint
}
