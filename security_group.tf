resource "aws_security_group" "jenkins_server" {
description = "Allow SSH and Jenkins Web UI"
name        = "jenkins_server"

# define the permissions for inbound traffic.
ingress {
description = "SSH"
from_port   = 22
to_port     = 22
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"] 
}

# define the permissions for inbound traffic.
ingress {
description = "Jenkins Web UI"
from_port   = 8080
to_port     = 8080
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"] 
}

# define the permissions for outbound traffic.
egress {
from_port   = 0
to_port     = 0
protocol    = "-1" # This setting indicates that all protocols are allowed. In AWS security group rules, "-1" represents all IP protocols, including TCP, UDP, and ICMP, among others.
cidr_blocks = ["0.0.0.0/0"] # it is a special CIDR block used to represent any address on the internet.
}
}
