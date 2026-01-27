variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "service_name" {
  description = "Service name (e.g., user, product)"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS Cluster name"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS Service name"
  type        = string
}

variable "prod_listener_arns" {
  description = "Production Listener ARNs (external + internal)"
  type        = list(string)
}

variable "test_listener_arn" {
  description = "ALB Test Listener ARN"
  type        = string
}

variable "blue_target_group_name" {
  description = "Blue Target Group name"
  type        = string
}

variable "green_target_group_name" {
  description = "Green Target Group name"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "CodeDeploy IAM Role ARN"
  type        = string
}

variable "termination_wait_time" {
  description = "Minutes to wait before terminating old tasks after traffic shift"
  type        = number
  default     = 5
}
