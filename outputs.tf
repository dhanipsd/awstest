output "public_ip" {
  value = aws_instance.node.public_ip
}

output "ssh_command" {
  value = "ssh -i ${var.private_key_path} centos@${aws_instance.node.public_ip}"
}
