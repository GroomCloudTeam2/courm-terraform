# 1. 브로커 인스턴스 (Zone A: 2대)
resource "aws_instance" "broker_zone_a" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type

  subnet_id              = var.subnet_ids[0]       # 첫 번째 서브넷 (Zone A)
  vpc_security_group_ids = var.security_group_ids  # 받아온 SG 장착
  key_name               = var.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "courm-kafka-a-${count.index + 1}"
    Role = "kafka-broker"
  }
}

# 2. 브로커 인스턴스 (Zone C: 1대)
resource "aws_instance" "broker_zone_c" {
  count                  = 1
  ami                    = var.ami_id
  instance_type          = var.instance_type

  subnet_id              = var.subnet_ids[1]       # 두 번째 서브넷 (Zone C)
  vpc_security_group_ids = var.security_group_ids  # 받아온 SG 장착
  key_name               = var.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "courm-kafka-c-${count.index + 1}"
    Role = "kafka-broker"
  }
}
