output "cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.this.name
}

output "execution_role_arn" {
  description = "ECS Task Execution Role ARN"
  value       = aws_iam_role.execution_role.arn
}

output "namespace_arn" {
  description = "Service Connect Namespace ARN"
  value       = aws_service_discovery_http_namespace.this.arn
}

output "codedeploy_role_arn" {
  description = "CodeDeploy Service Role ARN"
  value       = aws_iam_role.codedeploy_role.arn
}
