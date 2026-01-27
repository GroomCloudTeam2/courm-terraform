output "app_name" {
  description = "CodeDeploy Application name"
  value       = var.app_name
}

output "deployment_group_name" {
  description = "CodeDeploy Deployment Group name"
  value       = aws_codedeploy_deployment_group.this.deployment_group_name
}
