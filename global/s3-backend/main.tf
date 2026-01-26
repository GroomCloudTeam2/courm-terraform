# terraform/global/s3-backend/main.tf

provider "aws" {
  region = "ap-northeast-2"
}

# 1. S3 버킷 생성 (State 파일 저장소)
resource "aws_s3_bucket" "terraform_state" {
  # 주의: 버킷 이름은 전 세계에서 유일해야 합니다! (뒤에 프로젝트명이나 난수를 붙이세요)
  bucket = "courm-ecommerce-tf-state-storage" 
  
  # 실수로 삭제 방지 (매우 중요)
  lifecycle {
    prevent_destroy = true
  }
}

# 2. 버저닝 활성화 (실수 복구용)
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. 암호화 설정 (보안)
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. DynamoDB 테이블 생성 (Locking용)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "courm-ecommerce-tf-locks"
  billing_mode = "PAY_PER_REQUEST" # 무료/소액 과금
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# 5. 결과 출력 (나중에 복사해서 쓰기 위함)
output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}