output "jcasc_public_ip" {
  value = aws_instance.jcasc.public_ip 
}

output "jcasc_public_dns" {
  value = aws_instance.jcasc.public_dns 
}

