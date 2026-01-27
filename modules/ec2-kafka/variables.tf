variable "project_name" {}
variable "environment" {}

variable "security_group_ids" {
  description = "Kafka 인스턴스에 적용할 보안 그룹 ID 리스트"
  type        = list(string)
}

variable "subnet_ids" {
  description = "MQ 서브넷 ID 리스트 ([0]: A존, [1]: C존)"
  type        = list(string)
}

variable "key_name" {}
variable "ami_id" {}
variable "instance_type" {}
