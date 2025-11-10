output "vpc_id" {
  value       = aws_vpc.this.id
  description = "ID створеного VPC"
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public : s.id]
  description = "Список ID публічних підмереж"
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private : s.id]
  description = "Список ID приватних підмереж"
}

output "igw_id" {
  value       = aws_internet_gateway.this.id
  description = "ID Internet Gateway"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.this.id
  description = "ID NAT Gateway"
}