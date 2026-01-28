# ------------------------------------------------------------------------------
# Internal ALB (서비스 간 통신용, VPC 내부 전용)
# ------------------------------------------------------------------------------
resource "aws_lb" "internal" {
  name               = var.name
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  tags = {
    Name = var.name
  }
}

# ------------------------------------------------------------------------------
# 리스너 (HTTP:80) — Path 기반 라우팅
# ------------------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["user"].arn
  }
}

# ------------------------------------------------------------------------------
# Path 기반 라우팅 규칙
# ------------------------------------------------------------------------------
locals {
  routing_rules = {
    user    = { path = "/users*",    priority = 10 }
    product = { path = "/products*", priority = 20 }
    order   = { path = "/orders*",   priority = 30 }
    payment = { path = "/payments*", priority = 40 }
    cart    = { path = "/carts*",    priority = 50 }
  }
}

# Internal ALB 전용 타겟 그룹 생성
resource "aws_lb_target_group" "services" {
  for_each = local.routing_rules

  name        = "${var.name}-${each.key}-tg"
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

resource "aws_lb_listener_rule" "service" {
  for_each = local.routing_rules

  listener_arn = aws_lb_listener.http.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services[each.key].arn
  }

  condition {
    path_pattern {
      values = [each.value.path]
    }
  }
}
