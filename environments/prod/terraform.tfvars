# 환경 설정
project     = "courm"
environment = "prod"
region       = "ap-northeast-2"

# --- 네트워크 (Prod 환경) ---
vpc_cidr     = "10.0.0.0/16"
azs = ["ap-northeast-2a", "ap-northeast-2c"]

public_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
app_subnets    = ["10.0.10.0/24", "10.0.11.0/24"]
mq_subnets     = ["10.0.20.0/24", "10.0.21.0/24"]
mgmt_subnets   = ["10.0.30.0/24"] # A존 1개만 사용
data_subnets   = ["10.0.40.0/24", "10.0.41.0/24"]

# --- EC2 Key Pair ---
key_pair_name = "courm-prod-key"

# --- Jenkins ---
jenkins_ami_id        = "ami-010be25c3775061c9" # Ubuntu 22.04
jenkins_instance_type = "t3.large"

# --- Kafka ---
kafka_ami_id        = "ami-010be25c3775061c9" # Ubuntu 22.04
kafka_instance_type = "t3.medium"

# --- Database ---
db_username = "courm-admin"
db_password = "corumadmin1234!"
