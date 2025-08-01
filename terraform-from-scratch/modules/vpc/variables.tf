variable "vpc_name" {
  description = "Name of VPC"
  default     = "eks-vpc"
}

variable "vpc_cidr" {
  description = "CIDR of VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.12.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.14.0/24", "10.0.16.0/24"]
}