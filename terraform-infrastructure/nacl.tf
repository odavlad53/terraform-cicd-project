resource "aws_network_acl" "private" {
    vpc_id       = aws_vpc.this.id
    subnet_ids   = [for s in aws_subnet.private : s.id]

    # Deny inbound from placeholder bad range
    ingress {
        rule_no    = 90
        protocol   = "-1"
        action     = "deny"
        cidr_block = "198.51.100.0/24"
        from_port  = 0
        to_port    = 0
    }

    # Allow inbound from VPC (internal traffic) 
    ingress {
         protocol   = "-1"
         rule_no    = 100
         action     = "allow"
         cidr_block = "10.0.0.0/16"
         from_port  = 0
         to_port    = 0

    }
    # Allow return traffic
    ingress {
        rule_no    = 110
        protocol   = "tcp"
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 1024
        to_port    = 65535

    }

    # Allow outbound traffic
    egress {
        rule_no    = 100
        protocol   = "-1"
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }
tags = {
    Name = "private"
  }
}