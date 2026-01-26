# 환경 이름 (예: dev, prod)
variable "environment" {
  type        = string
  description = "배포 환경 이름"
}

# VPC 전체 IP 대역
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR 블록"
}

# 가용영역 (AZ) 리스트
variable "azs" {
  type        = list(string)
  description = "사용할 가용영역 리스트"
}

# --- 서브넷 CIDR 리스트 ---

variable "public_subnets" {
  type        = list(string)
  description = "Public Subnet CIDR)"
}

variable "app_subnets" {
  type        = list(string)
  description = "App(ECS) Subnet CIDR 리스트"
}

variable "mq_subnets" {
  type        = list(string)
  description = "MQ(Kafka) Subnet CIDR 리스트"
}

variable "mgmt_subnets" {
  type        = list(string)
  description = "Mgmt(Jenkins) Subnet CIDR 리스트"
}

variable "data_subnets" {
  type        = list(string)
  description = "Data(RDS/Redis) Subnet CIDR 리스트"
}
