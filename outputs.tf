output "jenkins_master_public_dns" {
  description = "Output the Jenkins server public DNS"
  value       = aws_instance.jenkins_ec2.public_dns
}

output "tomcat_public_dns" {
  description = "Output the tomcat server public DNS"
  value       = aws_instance.tomcat.public_dns
}


