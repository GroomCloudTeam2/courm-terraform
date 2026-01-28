output "dns_name" {
  description = "Internal ALB DNS name"
  value       = aws_lb.internal.dns_name
}

output "listener_arn" {
  description = "Internal ALB Listener ARN"
  value       = aws_lb_listener.http.arn
}

output "target_group_arns" {
  description = "Internal ALB Target Group ARNs"
  value       = { for k, v in aws_lb_target_group.services : k => v.arn }
}
