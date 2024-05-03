output "jcasc_public_ip" {
  value       = module.jcasc.jcasc_public_ip
  description = "Public IP of EC2"
}

output "jcasc_public_dns" {
  value = module.jcasc.jcasc_public_dns
}


