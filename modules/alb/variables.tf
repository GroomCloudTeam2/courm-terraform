variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "ALB가 위치할 Public Subnet ID 목록"
  type        = list(string)
}
