resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
    Environment = "Development"
    Owner = "Srilekha"
    Project = "EKS-Fintech-LLM"
    Terraform = "true"
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
    Environment = "Development"
    Owner = "Srilekha"
    Project = "EKS-Fintech-LLM"
    Terraform = "true"
  }
}

resource "aws_subnet" "public_subnets" {
  vpc_id     = aws_vpc.eks_vpc.id
  count      = length(var.public_subnets)
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-${count.index + 1}"
    Environment = "Development"
    Owner = "Srilekha"
    Project = "EKS-Fintech-LLM"
    Terraform = "true"
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id     = aws_vpc.eks_vpc.id
  count      = length(var.private_subnets)
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-private-${count.index + 1}"
    Environment = "Development"
    Owner = "Srilekha"
    Project = "EKS-Fintech-LLM"
    Terraform = "true"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
    Environment = "Development"
    Owner = "Srilekha"
    Project = "EKS-Fintech-LLM"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "public_rta" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "eks_eip" {
  domain = "vpc"
  tags = {
    Name = "${var.vpc_name}-nat-eip"
    Environment = "Development"
    Owner = "Srilekha"
    Project = "EKS-Fintech-LLM"
    Terraform = "true"
  }
}

resource "aws_nat_gateway" "eks_nat" {
  subnet_id     = aws_subnet.public_subnets[0].id
  allocation_id = aws_eip.eks_eip.id

  tags = {
    Name = "${var.vpc_name}-nat-gateway"
    Environment = "Development"
    Owner = "Srilekha"
    Project = "EKS-Fintech-LLM"
    Terraform = "true"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat.id
  }
  tags = {
    Name = "${var.vpc_name}-private-rt"
    Environment = "Development"
    Owner = "Srilekha"
    Project = "EKS-Fintech-LLM"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "private_rta" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_flow_log" "eks_flow_log" {
  vpc_id         = aws_vpc.eks_vpc.id
  iam_role_arn = aws_iam_role.vpc_flow_log_role.arn
  traffic_type   = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_group.arn

  tags = {
    Name = "${var.vpc_name}-flow-log"
    Environment = "Development"
    Owner = "Srilekha"
    Project = "EKS-Fintech-LLM"
    Terraform = "true"
  }
}

resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name = "/aws/vpc/flow-logs/${var.vpc_name}"

  retention_in_days = 7

  tags = {
    Name = "${var.vpc_name}-flow-log-group"
    Environment = "Development"
    Owner = "Srilekha"
    Project = "EKS-Fintech-LLM"
    Terraform = "true"
  }
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name = "${var.vpc_name}-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.vpc_name}-flow-log-role"
    Environment = "Development"
    Owner = "Srilekha"
    Project = "EKS-Fintech-LLM"
    Terraform = "true"
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_policy_attachment" {
  role       = aws_iam_role.vpc_flow_log_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}