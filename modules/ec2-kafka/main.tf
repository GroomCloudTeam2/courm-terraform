# ----------------------------------------------------------------
# 1. SSM 접속을 위한 IAM 권한 설정
# ----------------------------------------------------------------
# 1-1. 역할을 생성 (EC2가 사용할 수 있도록 신뢰 관계 설정)
resource "aws_iam_role" "kafka_ssm_role" {
  name = "courm-kafka-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 1-2. AWS 관리형 정책(SSM Core)을 역할에 붙임
resource "aws_iam_role_policy_attachment" "kafka_ssm_policy" {
  role       = aws_iam_role.kafka_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 1-3. EC2에 갖다 붙일 수 있게 '인스턴스 프로파일'로 포장
resource "aws_iam_instance_profile" "kafka_ssm_profile" {
  name = "courm-kafka-ssm-profile"
  role = aws_iam_role.kafka_ssm_role.name
}

# ----------------------------------------------------------------
# 2. EC2 인스턴스 생성 (IAM 프로파일 연결)
# ----------------------------------------------------------------

# 2-1. 브로커 인스턴스 (Zone A: 2대)
resource "aws_instance" "broker_zone_a" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type

  subnet_id              = var.subnet_ids[0]       # 첫 번째 서브넷 (Zone A)
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  iam_instance_profile   = aws_iam_instance_profile.kafka_ssm_profile.name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "courm-kafka-a-${count.index + 1}"
    Role = "kafka-broker"
  }
}

# 2-2. 브로커 인스턴스 (Zone C: 1대)
resource "aws_instance" "broker_zone_c" {
  count                  = 1
  ami                    = var.ami_id
  instance_type          = var.instance_type

  subnet_id              = var.subnet_ids[1]       # 두 번째 서브넷 (Zone C)
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  iam_instance_profile   = aws_iam_instance_profile.kafka_ssm_profile.name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "courm-kafka-c-${count.index + 1}"
    Role = "kafka-broker"
  }
}
