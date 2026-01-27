# courm-terraform/variables.tf

variable "environment" { type = string }
variable "vpc_cidr" { type = string }
variable "azs" { type = list(string) }
variable "public_subnets" { type = list(string) }
variable "app_subnets" { type = list(string) }
variable "mq_subnets" { type = list(string) }
variable "mgmt_subnets" { type = list(string) }
variable "data_subnets" { type = list(string) }
variable "jenkins_ami_id" {
  description = "젠킨스 인스턴스에 사용할 AMI ID"
  type        = string
}

variable "key_pair_name" {
  description = "EC2 접속에 사용할 SSH 키페어 이름"
  type        = string
}

# RDS 변수
variable "rds_username" {
  description = "RDS 마스터 사용자 이름"
  type        = string
  default     = "admin"
}

