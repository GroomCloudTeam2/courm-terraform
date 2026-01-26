output "alb_dns_name" {
  description = "로드밸런서 접속 주소 (DNS)"
  value       = aws_lb.main.dns_name
}

output "alb_listener_arn" {
  description = "리스너 ARN (API Gateway 연결용)"
  value       = aws_lb_listener.http.arn
}

# ECS 모듈에서 가져다 쓸 타겟 그룹 ARN들
output "target_group_arns" {
  description = "서비스별 타겟 그룹 ARN 맵"
  value = {
    user    = aws_lb_target_group.user.arn
    product = aws_lb_target_group.product.arn
    order   = aws_lb_target_group.order.arn
    payment = aws_lb_target_group.payment.arn
    cart = aws_lb_target_group.cart.arn
  }
}
