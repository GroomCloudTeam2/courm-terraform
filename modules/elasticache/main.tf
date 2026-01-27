# modules/elasticache/main.tf

# 0. Auth Token 자동 생성 (사용자가 입력하지 않은 경우)
resource "random_password" "auth_token" {
  count            = var.auth_token == null ? 1 : 0
  length           = 32 # Redis 토큰은 충분히 길게
  special          = false # 일부 특수문자는 Redis URL 등에서 문제될 수 있어 안전하게 false 추천 (혹은 override)
}

locals {
  auth_token = var.auth_token != null ? var.auth_token : random_password.auth_token[0].result
}

# 1. AWS Secrets Manager에 토큰 저장
resource "aws_secretsmanager_secret" "redis_credentials" {
  name        = "elasticache/${var.cluster_id}/auth-token"
  description = "Auth token for ElastiCache Redis ${var.cluster_id}"
  recovery_window_in_days = 0

  tags = merge(var.tags, {
    Name        = "redis-secret-${var.cluster_id}"
    Environment = var.environment
  })
}

resource "aws_secretsmanager_secret_version" "redis_credentials" {
  secret_id     = aws_secretsmanager_secret.redis_credentials.id
  secret_string = jsonencode({
    auth_token = local.auth_token
    host       = aws_elasticache_replication_group.this.primary_endpoint_address
    port       = aws_elasticache_replication_group.this.port
    cluster_id = var.cluster_id
  })
}

# 서브넷 그룹
resource "aws_elasticache_subnet_group" "this" {
  name        = "${var.cluster_id}-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Subnet group for ${var.cluster_id}"

  tags = merge(var.tags, {
    Name        = "${var.cluster_id}-subnet-group"
    Environment = var.environment
  })
}

# 파라미터 그룹
resource "aws_elasticache_parameter_group" "this" {
  name   = "${var.cluster_id}-params"
  family = var.parameter_group_family

  # 메모리 정책: 만료 키 중 가장 오래된 것부터 제거
  parameter {
    name  = "maxmemory-policy"
    value = "volatile-lru"
  }

  tags = merge(var.tags, {
    Name        = "${var.cluster_id}-params"
    Environment = var.environment
  })
}

# Redis Replication Group (Primary + Replica)
resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.cluster_id
  description          = "Redis cluster for ${var.cluster_id}"

  # 엔진 설정
  engine               = var.engine
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = var.port
  parameter_group_name = aws_elasticache_parameter_group.this.name

  # 클러스터 설정
  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled

  # 네트워크 설정
  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = var.security_group_ids

  # 스냅샷 설정
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window

  # 유지보수 설정
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # 암호화 설정
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = var.transit_encryption_enabled ? local.auth_token : null

  tags = merge(var.tags, {
    Name        = var.cluster_id
    Environment = var.environment
  })
}