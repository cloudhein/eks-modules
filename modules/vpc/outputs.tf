output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the created VPC"
}

output "vpc_cidr_block" {
  value       = aws_vpc.main.cidr_block
  description = "The CIDR block of the VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public_subnet[*].id
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value       = aws_subnet.private_subnet[*].id
  description = "List of private subnet IDs"
}

output "availability_zones" {
  value       = data.aws_availability_zones.available.names
  description = "List of availability zones used for subnets"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "ID of the Internet Gateway"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.nat.id
  description = "ID of the NAT Gateway"
}

output "nat_eip" {
  value       = aws_eip.nat_eip.public_ip
  description = "Elastic IP assigned to the NAT Gateway"
}

output "public_route_table_id" {
  value       = aws_route_table.public_rt.id
  description = "Route table ID for the public subnets"
}

output "private_route_table_id" {
  value       = aws_route_table.private_rt.id
  description = "Route table ID for the private subnets"
}
