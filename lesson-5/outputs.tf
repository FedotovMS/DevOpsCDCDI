output "instance_public_ip" {
  value = aws_instance.demo.private_ip
}
