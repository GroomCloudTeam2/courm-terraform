# courm-terraform/variables.tf

variable "environment" { type = string }
variable "vpc_cidr" { type = string }
variable "azs" { type = list(string) }
variable "public_subnets" { type = list(string) }
variable "app_subnets" { type = list(string) }
variable "mq_subnets" { type = list(string) }
variable "mgmt_subnets" { type = list(string) }
variable "data_subnets" { type = list(string) }
