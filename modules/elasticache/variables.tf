# modules/elasticache/variables.tf

variable "cluster_id" {
  description = "ElastiCache 클러스터 식별자"
  type        = string
}

variable "environment" {
  description = "환경 (prod, dev, staging)"
  type        = string
}

variable "engine" {
  description = "캐시 엔진 (redis)"
  type        = string
  default     = "redis"
}

variable "engine_version" {
  description = "Redis 엔진 버전"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "노드 인스턴스 타입"
  type        = string
  default     = "cache.t4g.micro"
}

variable "port" {
  description = "Redis 포트"
  type        = number
  default     = 6379
}

variable "parameter_group_family" {
  description = "파라미터 그룹 패밀리"
  type        = string
  default     = "redis7"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "ElastiCache 서브넷 ID 리스트"
  type        = list(string)
}

variable "security_group_ids" {
  description = "보안 그룹 ID 리스트"
  type        = list(string)
  default     = []
}

# Cluster Mode 설정
variable "num_cache_clusters" {
  description = "클러스터 내 노드 수 (Replication Group용)"
  type        = number
  default     = 2
}

variable "automatic_failover_enabled" {
  description = "자동 장애 조치 활성화 (노드 2개 이상 필요)"
  type        = bool
  default     = true
}

variable "multi_az_enabled" {
  description = "Multi-AZ 활성화"
  type        = bool
  default     = true
}

# 스냅샷 설정
variable "snapshot_retention_limit" {
  description = "스냅샷 보관 기간 (일, 0이면 비활성화)"
  type        = number
  default     = 1
}

variable "snapshot_window" {
  description = "스냅샷 윈도우 (UTC)"
  type        = string
  default     = "03:00-04:00"
}

# 유지보수 설정
variable "maintenance_window" {
  description = "유지보수 윈도우 (UTC)"
  type        = string
  default     = "mon:04:00-mon:05:00"
}

variable "auto_minor_version_upgrade" {
  description = "마이너 버전 자동 업그레이드"
  type        = bool
  default     = true
}

# 암호화 설정
variable "at_rest_encryption_enabled" {
  description = "저장 데이터 암호화 활성화"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "전송 데이터 암호화 활성화"
  type        = bool
  default     = true
}

variable "auth_token" {
  description = "Redis AUTH 토큰 (전송 암호화 활성화 시 필수)"
  type        = string
  sensitive   = true
  default     = null
}

variable "tags" {
  description = "추가 태그"
  type        = map(string)
  default     = {}
}
