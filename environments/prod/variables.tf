# courm-terraform/variables.tf

variable "project" {
  description = "Project name"
  type        = string
  default     = "courm"
}

variable "environment" {
  description = "환경 이름 (예: prod)"
  type        = string
}

variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

# --- 네트워크 ---
variable "vpc_cidr" { type = string }
variable "azs" { type = list(string) }
variable "public_subnets" { type = list(string) }
variable "app_subnets" { type = list(string) }
variable "mq_subnets" { type = list(string) }
variable "mgmt_subnets" { type = list(string) }
variable "data_subnets" { type = list(string) }

# --- Database (RDS) ---
variable "db_username" {
  description = "DB 마스터 사용자명"
  type        = string
}

variable "db_password" {
  description = "DB 마스터 비밀번호"
  type        = string
  sensitive   = true # 로그에 안 찍히게 설정
}

# --- Jenkins ---
variable "jenkins_ami_id" { type = string }
variable "jenkins_instance_type" { type = string }
variable "key_pair_name" { type = string }

# --- Kafka ---
variable "kafka_ami_id" { type = string }
variable "kafka_instance_type" { type = string }
