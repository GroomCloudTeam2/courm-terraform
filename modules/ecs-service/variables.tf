# Core
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

# Cluster & IAM
variable "cluster_id" {
  description = "ECS Cluster ID"
  type        = string
}

variable "execution_role_arn" {
  description = "Task Execution Role ARN"
  type        = string
}

# Container Spec
variable "container_image" {
  description = "Container Image URI"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "CPU units (256, 512, 1024, etc.)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MB (512, 1024, 2048, etc.)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

# Network
variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID for the service"
  type        = string
}

variable "assign_public_ip" {
  description = "Assign public IP to tasks"
  type        = bool
  default     = false
}

# Load Balancer
variable "target_group_arn" {
  description = "ALB Target Group ARN"
  type        = string
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 60
}

# Environment & Logs
variable "environment_variables" {
  description = "List of environment variables"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 14
}

variable "green_target_group_arn" {
  description = "Green Target Group ARN (Blue/Green 배포용)"
  type        = string
  default     = ""
}

variable "internal_target_group_arn" {
  description = "Internal ALB Target Group ARN (Optional)"
  type        = string
  default     = ""
}
