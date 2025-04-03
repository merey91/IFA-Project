#
output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.dns_name
}

#
output "jenkins_elastic_ip" {
  description = "Elastic IP of the Jenkins instance"
  value       = aws_eip.jenkins_eip.public_ip
}
