variable "region" {
  description = "Region to deploy resources"
  type = string
  default = "us-east-1"
}

variable "vpc_name" {
  description = "Name of VPC"
  type = string
  default = "eks-vpc"
}

variable "vpc_cidr" {
  description = "CIDR of VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Name of VPC"
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  description = "Public Subnets of VPC"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Private Subnets of VPC"
  type = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "cluster_name" {
  description = "Name of EKS Cluster"
  type = string
  default = "EKSCluster"
}

variable "cluster_version" {
  description = "Version of EKS Cluster"
  type = string
  default = "1.32"
}

variable "environment" {
  description = "Environment to deploy resources"
  type = string
  default = "Production"
}
