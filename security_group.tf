resource "aws_security_group" "jenkins_server" {
description = "Allow SSH and Jenkins Web UI"
name        = "jenkins_server"

ingress {
description = "SSH"
from_port   = 22
to_port     = 22
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"] 
}

ingress {
description = "Jenkins Web UI"
from_port   = 8080
to_port     = 8080
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"] 
}

egress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}
