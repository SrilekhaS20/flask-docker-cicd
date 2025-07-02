provider "aws" {
  region = var.region
}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "5.1.1"
  name                 = var.vpc_name
  cidr                 = var.vpc_cidr
  azs                  = var.availability_zones
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

module "eks" {
  source                                   = "terraform-aws-modules/eks/aws"
  version                                  = "20.37.1"
  cluster_name                             = var.cluster_name
  cluster_version                          = var.cluster_version
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  enable_irsa                              = true
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
}
