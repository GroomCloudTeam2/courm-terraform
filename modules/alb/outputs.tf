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

output "target_group_arns_green" {
  description = "서비스별 Green 타겟 그룹 ARN 맵 (Blue/Green 배포용)"
  value = {
    user    = aws_lb_target_group.user_green.arn
    product = aws_lb_target_group.product_green.arn
    order   = aws_lb_target_group.order_green.arn
    payment = aws_lb_target_group.payment_green.arn
    cart    = aws_lb_target_group.cart_green.arn
  }
}

output "target_group_names" {
  description = "서비스별 Blue 타겟 그룹 이름 맵"
  value = {
    user    = aws_lb_target_group.user.name
    product = aws_lb_target_group.product.name
    order   = aws_lb_target_group.order.name
    payment = aws_lb_target_group.payment.name
    cart    = aws_lb_target_group.cart.name
  }
}

output "target_group_names_green" {
  description = "서비스별 Green 타겟 그룹 이름 맵"
  value = {
    user    = aws_lb_target_group.user_green.name
    product = aws_lb_target_group.product_green.name
    order   = aws_lb_target_group.order_green.name
    payment = aws_lb_target_group.payment_green.name
    cart    = aws_lb_target_group.cart_green.name
  }
}

output "test_listener_arn" {
  description = "테스트 리스너 ARN (Blue/Green 배포 검증용)"
  value       = aws_lb_listener.test.arn
}
