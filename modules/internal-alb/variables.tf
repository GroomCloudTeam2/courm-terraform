variable "name" {
  description = "Internal ALB name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "App subnet IDs (Private, 최소 2개 AZ)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for internal ALB"
  type        = list(string)
}

variable "service_names" {
  description = "List of service names to create target groups and rules for"
  type        = list(string)
  default     = ["user", "product", "order", "payment", "cart"]
}

variable "default_target_group_arn" {
  description = "기본 라우팅 Target Group ARN"
  type        = string
}
