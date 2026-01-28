# 생성된 VPC ID
output "vpc_id" {
  value = aws_vpc.this.id
}

# --- 서브넷 ID 리스트 ---

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
  description = "Public Subnet ID"
}

output "app_subnet_ids" {
  value = aws_subnet.app[*].id
  description = "App Subnet IDs"
}

output "mq_subnet_ids" {
  value = aws_subnet.mq[*].id
  description = "MQ Subnet IDs"
}

output "mq_subnet_cidrs" {
  value = aws_subnet.mq[*].cidr_block
}

output "mgmt_subnet_ids" {
  value = aws_subnet.mgmt[*].id
  description = "Mgmt Subnet IDs"
}

output "data_subnet_ids" {
  value = aws_subnet.data[*].id
  description = "Data Subnet IDs"
}

# --- 기타 정보 ---

output "nat_gateway_ip" {
  value = aws_eip.nat[0].public_ip
  description = "NAT Gateway의 고정 공인 IP"
}

output "s3_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}
