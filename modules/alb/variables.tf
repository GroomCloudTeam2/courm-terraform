variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "ALB가 위치할 Public Subnet ID 목록"
  type        = list(string)
}

variable "security_group_ids" {
  description = "ALB에 적용할 보안 그룹 ID 리스트"
  type        = list(string)
}
