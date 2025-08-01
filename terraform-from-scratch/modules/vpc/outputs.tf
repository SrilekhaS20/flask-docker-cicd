output "vpc_id" {
    value = aws_vpc.eks_vpc.id
}

output "public_subnet_ids" {
    value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
    value = aws_subnet.private_subnets[*].id
}

output "public_route_table_id" {
    value = aws_route_table.public_rt.id
}

output "private_route_table_id" {
    value = aws_route_table.private_rt.id
}

output "nat_gateway_id" {
    value = aws_nat_gateway.eks_nat.id
}

output "nat_eip" {
    value = aws_eip.eks_eip.id
}

output "internet_gateway_id" {
    value = aws_internet_gateway.eks_igw.id
}