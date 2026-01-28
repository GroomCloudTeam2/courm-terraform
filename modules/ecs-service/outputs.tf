output "service_id" {
  description = "ECS Service ID"
  value       = aws_ecs_service.this.id
}

output "service_name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "Task Definition ARN"
  value       = aws_ecs_task_definition.this.arn
}

output "log_group_name" {
  description = "CloudWatch Log Group Name"
  value       = aws_cloudwatch_log_group.this.name
}
