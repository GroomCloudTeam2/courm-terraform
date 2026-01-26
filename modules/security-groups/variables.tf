  variable "name" {
    type = string
  }

  variable "vpc_id" {
    type = string
  }

  variable "ingress_rules" {
    type = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
    }))
    default = []
  }

  variable "egress_rules" {
    type = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
    }))
    # 기본값: 아웃바운드 전체 허용
    default = [{
      from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"], security_groups = []
    }]
  }
