# 1. 최종 사용자 접속용 URL (API Gateway)
output "api_gateway_endpoint" {
  description = "최종 API 접속 주소 (여기로 요청을 보내세요)"
  value       = module.api_gateway.api_endpoint
}

# 2. 디버깅용 ALB 주소
output "alb_dns_name" {
  description = "ALB의 DNS 주소"
  value       = module.alb.alb_dns_name
}

# 3. VPC ID 확인
output "vpc_id" {
  description = "생성된 VPC ID"
  value       = module.vpc.vpc_id
}
