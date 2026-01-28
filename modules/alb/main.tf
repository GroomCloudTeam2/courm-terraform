# 1. ALB 전용 보안 그룹
  resource "aws_lb" "main" {
    name               = "courm-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = var.security_group_ids
    subnets            = var.public_subnets

    tags = {
      Name = "courm-alb"
    }
  }

  # -----------------------------------------------------------
  # 3. 타겟 그룹 생성
  # -----------------------------------------------------------

  # (1) User 서비스용 타겟 그룹
  resource "aws_lb_target_group" "user" {
    name        = "courm-user-tg"
    port        = 8080
    protocol    = "HTTP"
    target_type = "ip" # ECS Fargate를 쓸 경우 ip로 설정해야 함
    vpc_id      = var.vpc_id

    health_check {
      path = "/health" # 혹은 "/"
    }

    lifecycle {
      create_before_destroy = true
    }
  }

  # (2) Product 서비스용 타겟 그룹
  resource "aws_lb_target_group" "product" {
    name        = "courm-product-tg"
    port        = 8080
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = var.vpc_id

    health_check {
      path = "/health"
    }

    lifecycle {
      create_before_destroy = true
    }
  }

  # (3) Order 서비스용 타겟 그룹
  resource "aws_lb_target_group" "order" {
    name        = "courm-order-tg"
    port        = 8080
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = var.vpc_id

    health_check {
      path = "/health"
    }

    lifecycle {
      create_before_destroy = true
    }
  }

  # (4) Payment 서비스용 타겟 그룹
  resource "aws_lb_target_group" "payment" {
    name        = "courm-payment-tg"
    port        = 8080
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = var.vpc_id

    health_check {
      path = "/health"
    }

    lifecycle {
      create_before_destroy = true
    }
  }

  # (5) Cart 서비스용 타겟 그룹
  resource "aws_lb_target_group" "cart" {
    name        = "courm-cart-tg"
    port        = 8080
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = var.vpc_id
    health_check { path = "/health" }

    lifecycle {
      create_before_destroy = true
    }
  }

  # -----------------------------------------------------------
  # 3-2. Green 타겟 그룹 (Blue/Green 배포용)
  # -----------------------------------------------------------

  resource "aws_lb_target_group" "user_green" {
    name        = "courm-user-tg-green"
    port        = 8080
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = var.vpc_id

    health_check {
      path = "/health"
    }

    lifecycle {
      create_before_destroy = true
    }
  }

  resource "aws_lb_target_group" "product_green" {
    name        = "courm-product-tg-green"
    port        = 8080
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = var.vpc_id

    health_check {
      path = "/health"
    }

    lifecycle {
      create_before_destroy = true
    }
  }

  resource "aws_lb_target_group" "order_green" {
    name        = "courm-order-tg-green"
    port        = 8080
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = var.vpc_id

    health_check {
      path = "/health"
    }

    lifecycle {
      create_before_destroy = true
    }
  }

  resource "aws_lb_target_group" "payment_green" {
    name        = "courm-payment-tg-green"
    port        = 8080
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = var.vpc_id

    health_check {
      path = "/health"
    }

    lifecycle {
      create_before_destroy = true
    }
  }

  resource "aws_lb_target_group" "cart_green" {
    name        = "courm-cart-tg-green"
    port        = 8080
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = var.vpc_id

    health_check {
      path = "/health"
    }

    lifecycle {
      create_before_destroy = true
    }
  }

  # -----------------------------------------------------------
  # 3-3. 테스트 리스너 (Green 환경 검증용, port 8080)
  # -----------------------------------------------------------

  resource "aws_lb_listener" "test" {
    load_balancer_arn = aws_lb.main.arn
    port              = 8080
    protocol          = "HTTP"

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.user_green.arn
    }
  }

  # 테스트 리스너 규칙 (Green 타겟 그룹 연결)
  resource "aws_lb_listener_rule" "user_green" {
    listener_arn = aws_lb_listener.test.arn
    priority     = 10

    action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.user_green.arn
    }

    condition {
      path_pattern {
        values = ["/users*"]
      }
    }
  }

  resource "aws_lb_listener_rule" "product_green" {
    listener_arn = aws_lb_listener.test.arn
    priority     = 20

    action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.product_green.arn
    }

    condition {
      path_pattern {
        values = ["/products*"]
      }
    }
  }

  resource "aws_lb_listener_rule" "order_green" {
    listener_arn = aws_lb_listener.test.arn
    priority     = 30

    action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.order_green.arn
    }

    condition {
      path_pattern {
        values = ["/orders*"]
      }
    }
  }

  resource "aws_lb_listener_rule" "payment_green" {
    listener_arn = aws_lb_listener.test.arn
    priority     = 40

    action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.payment_green.arn
    }

    condition {
      path_pattern {
        values = ["/payments*"]
      }
    }
  }

  resource "aws_lb_listener_rule" "cart_green" {
    listener_arn = aws_lb_listener.test.arn
    priority     = 50

    action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.cart_green.arn
    }

    condition {
      path_pattern {
        values = ["/carts*"]
      }
    }
  }

  # -----------------------------------------------------------
  # 4. 리스너 및 규칙 (교통 정리)
  # -----------------------------------------------------------

  # 기본 리스너 (일단 User 서비스로 보냄 - 혹은 404 리턴 설정 가능)
  resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.main.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.user.arn # 기본은 User로
    }
  }

  # 규칙 1: /users* 로 들어오면 -> User 타겟 그룹으로
  resource "aws_lb_listener_rule" "user" {
    listener_arn = aws_lb_listener.http.arn
    priority     = 10

    action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.user.arn
    }

    condition {
      path_pattern {
        values = ["/users*"]
      }
    }
  }

  # 규칙 2: /products* 로 들어오면 -> Product 타겟 그룹으로
  resource "aws_lb_listener_rule" "product" {
    listener_arn = aws_lb_listener.http.arn
    priority     = 20

    action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.product.arn
    }

    condition {
      path_pattern {
        values = ["/products*"]
      }
    }
  }

  # 규칙 3: /orders* 로 들어오면 -> Order 타겟 그룹으로
  resource "aws_lb_listener_rule" "order" {
    listener_arn = aws_lb_listener.http.arn
    priority     = 30

    action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.order.arn
    }

    condition {
      path_pattern {
        values = ["/orders*"]
      }
    }
  }

  # 규칙 4: /payments* 로 들어오면 -> Payment 타겟 그룹으로
  resource "aws_lb_listener_rule" "payment" {
    listener_arn = aws_lb_listener.http.arn
    priority     = 40

    action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.payment.arn
    }

    condition {
      path_pattern {
        values = ["/payments*"]
      }
    }
  }

  # 규칙 5: /cart* 로 들어오면 -> Cart 타겟 그룹으로
  resource "aws_lb_listener_rule" "cart" {
    listener_arn = aws_lb_listener.http.arn
    priority     = 50
    action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.cart.arn
    }
    condition {
      path_pattern { values = ["/carts*"] }
    }
  }