# courm-terraform/main.tf

# 1. VPC 모듈 호출
module "vpc" {
  source = "../../modules/vpc"

  environment    = var.environment
  vpc_cidr       = var.vpc_cidr
  azs            = var.azs
  public_subnets = var.public_subnets
  app_subnets    = var.app_subnets
  mq_subnets     = var.mq_subnets
  mgmt_subnets   = var.mgmt_subnets
  data_subnets   = var.data_subnets
}

# -----------------------------------------------------------
# 보안 그룹 (Security Groups)
# -----------------------------------------------------------

# (1) ALB SG
module "sg_alb" {
  source = "../../modules/security-groups"

  name   = "courm-sg-alb-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  ]
  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

# (2) ECS SG (From ALB)
module "sg_ecs" {
  source = "../../modules/security-groups"

  name   = "courm-sg-ecs-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    { from_port = 8080, to_port = 8080, protocol = "tcp", security_groups = [module.sg_alb.security_group_id] }
  ]
}

# (3) RDS SG (From ECS)
module "sg_rds" {
  source = "../../modules/security-groups"

  name   = "courm-sg-rds-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    { from_port = 5432, to_port = 5432, protocol = "tcp", security_groups = [module.sg_ecs.security_group_id] }
  ]
}

# (4) Redis SG (From ECS)
module "sg_redis" {
  source = "../../modules/security-groups"

  name   = "courm-sg-redis-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    { from_port = 6379, to_port = 6379, protocol = "tcp", security_groups = [module.sg_ecs.security_group_id] }
  ]
}

# (5) Jenkins SG
module "sg_jenkins" {
  source = "../../modules/security-groups"

  name   = "courm-sg-jenkins-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    { from_port = 8080, to_port = 8080, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 22,   to_port = 22,   protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  ]
  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

# (6) Kafka SG (From ECS & Self)
module "sg_kafka" {
  source = "../../modules/security-groups"

  name   = "courm-sg-kafka-${var.environment}"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 9092
      to_port         = 9092
      protocol        = "tcp"
      security_groups = [module.sg_ecs.security_group_id]
    },
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = module.vpc.mq_subnet_cidrs # 브로커 간 통신 (Self 대체)
    }
  ]
  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}


# -----------------------------------------------------------
# 리소스 모듈 (Resources)
# -----------------------------------------------------------

# 3. ALB
module "alb" {
  source = "../../modules/alb"

  vpc_id             = module.vpc.vpc_id
  public_subnets     = module.vpc.public_subnet_ids
  security_group_ids = [module.sg_alb.security_group_id]
}

# 4. API Gateway
module "api_gateway" {
  source = "../../modules/api-gateway"
  alb_dns_name = module.alb.alb_dns_name
}

# 5. RDS (Order, Product)
module "rds_order" {
  source = "../../modules/rds"

  identifier         = "courm-rds-order-${var.environment}"
  environment        = var.environment
  db_name            = "courm_order"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.data_subnet_ids
  security_group_ids = [module.sg_rds.security_group_id]

  # 변수 사용
  username           = var.db_username
  password           = var.db_password

  tags = { Service = "order-payment-user" }
}

module "rds_product" {
  source = "../../modules/rds"

  identifier         = "courm-rds-product-${var.environment}"
  environment        = var.environment
  db_name            = "courm_product"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.data_subnet_ids
  security_group_ids = [module.sg_rds.security_group_id]

  username           = var.db_username
  password           = var.db_password

  create_read_replica = true # Prod 환경 특화 설정은 여기 남겨도 됨

  tags = { Service = "product-review" }
}

# 6. Redis
module "elasticache_redis" {
  source = "../../modules/elasticache"

  cluster_id         = "courm-redis-${var.environment}"
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.data_subnet_ids
  security_group_ids = [module.sg_redis.security_group_id]

  tags = { Service = "product-cache-cart-lock" }
}

# 7. Jenkins
module "jenkins" {
  source = "../../modules/ec2-jenkins"

  name               = "courm-jenkins-${var.environment}"
  ami_id             = var.jenkins_ami_id
  instance_type      = var.jenkins_instance_type
  key_name           = var.key_pair_name
  subnet_id          = module.vpc.mgmt_subnet_ids[0]
  security_group_ids = [module.sg_jenkins.security_group_id]
}

# 8. Kafka
module "kafka" {
  source = "../../modules/ec2-kafka"

  environment        = var.environment
  subnet_ids         = module.vpc.mq_subnet_ids
  security_group_ids = [module.sg_kafka.security_group_id]

  ami_id             = var.kafka_ami_id
  instance_type      = var.kafka_instance_type
  key_name           = var.key_pair_name
}
