# Flask Docker App - Manual to CI/CD
A demo DevOps app to show how to deploy a Flask microservice to AWS EC2 using manual steps first, then automate using GitHub Actions.

![Flask App with EKS Cluster Architecture Diagram](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/eks_architecture_diagram.jpg)

## Step 1 - Run Locally (Without Docker)
Ensure Python 3.10+ is installed.
```bash
pip install -r requirements.txt
python app.py
```
#### Then visit:
#### http://localhost:5000/ → ✅ Shows welcome message

![Home Page](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/browser-homepage.jpg)

#### http://localhost:5000/health → ✅ Returns "ok"

![Health endpoint](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/browser-health.jpg)

#### http://localhost:5000/version → ✅ Returns version from version.txt

![Version endpoint](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/browser-version.jpg)

### Version
v1.0.0 - Manual setup base version

## 🐳 Step 2 – Dockerize & Run Locally

The Flask app is now containerized using Docker. This step simulates a local development environment for faster deployment and repeatable builds.

---

### 📁 Dockerfile Highlights

- Uses python:3.10-slim base image for smaller size
- Installs dependencies from requirements.txt
- Copies app code into the container
- Runs the Flask app on 0.0.0.0:5000 for external access

```Dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
```

---

⚙️ Docker Commands to Build & Run Locally

# Build the image
```
docker build -t flask-docker-cicd:v1 .

```
![Docker image build](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/docker-build-success.jpg)

![View Docker image](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/docker-images-1.jpg)


# Run the container
```
docker run -p 5000:5000 flask-docker-cicd:v1
```
![Docker run](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/docker-run-1.jpg)
---

✅ Verify App in Browser

#### Visit the following URLs in your browser (while the container is running):

#### http://localhost:5000/ → ✅ Shows welcome message

![Home Page](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/browser-homepage.jpg)

#### http://localhost:5000/health → ✅ Returns "ok"

![Health endpoint](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/browser-health.jpg)

#### http://localhost:5000/version → ✅ Returns version from version.txt

![Version endpoint](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/browser-version.jpg)

##### Push Image to DockerHub
```bash
docker login
docker tag flask-docker-cicd:v1 <docker_username>/flask-docker-cicd:v1
docker push <docker_username>/flask-docker-cicd:v1
```
## Step 3 - Create EKS Cluster (Manual Setup via Console)

### 🔧 Prerequisites

##### - AWS account with necessary IAM permissions
##### - AWS CLI & kubectl installed and configured
##### - Docker installed
##### - GitHub account (for code & image pushing)
##### - DockerHub account (to store your image)

### Step 3.1 – Create Cluster IAM Role

##### Go to IAM > Roles > Create Role

##### Choose: EKS – Cluster

##### Attach Policy: AmazonEKSClusterPolicy, AmazonEKSServicePolicy

##### Name it: AmazonEKSClusterRole


### Step 3.2 – Create EKS Cluster (Custom Config)

##### Go to EKS > Add Cluster > Create

##### Name: EKSCluster

##### Select the AmazonEKSClusterRole you just created

##### Networking:

##### You can use default VPC

##### Select 2 subnets (in different AZs)

##### Select/Create security group (allow inbound 80/443)



### Step 3.3 – Enable Cluster Access

##### Select Public and Private access

##### Optionally, restrict CIDR range to your IP


### Step 3.4 – Create Node Group (EC2 Worker Nodes)

##### IAM Role for Node Group

##### Go to IAM > Roles > Create Role

##### Choose: EKS – Node Group

##### Attach Policies:

##### AmazonEKSWorkerNodePolicy

##### AmazonEC2ContainerRegistryReadOnly

##### AmazonEKS_CNI_Policy

##### Name it: NodeGroupRole


### Step 3.5 – Add Managed Node Group

##### Select EC2 instance type: t3.medium (Free Tier eligible for limited use)

##### Use the role: NodeGroupRole

##### Name: node-group

##### Desired size - 2 nodes
##### Minimum size - 1 node
##### Maximum size - 3 nodes

##### Proceed and create the node group


### Step 3.6 - Configure kubectl with EKS Cluster

```bash
aws eks --region us-east-1 update-kubeconfig --name EKSCluster
```

### Step 3.7 - Deploy Flask App to EKS

#### Apply Kubernetes Manifests

```bash
kubectl apply -f eks_cluster/deployment.yaml
kubectl apply -f eks_cluster/service.yaml
```

#### Ensure deployment.yaml pulls image from DockerHub:

```deployment.yaml
containers:
  - name: flask-container
    image: <your-dockerhub-username>/flask-docker-cicd:v2
```

#### Check if deployements are created

```bash
kubectl get pods
```
![Pods](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/eks-pods.jpg)
```bash
kubectl get deploy
```
![Deployment](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/eks-deployments.jpg)

### Step 3.8 – Get Load Balancer IP

```bash
kubectl get svc flask-service
```
![Service](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/eks_lb_endpoint.jpg)

#### Access your Flask app in browser using EXTERNAL-IP of LoadBalancer


🌐 App Access

Once deployment is successful, open your browser:

```bash
http://<LoadBalancer-External-IP>
```
![Home Page](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/eks-flask-homepage.jpg)

```bash
http://<LoadBalancer-External-IP>/health
```
![Health endpoint](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/eks-flask-health.jpg)

```bash
http://<LoadBalancer-External-IP>/version
```
![Version endpoint](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/eks-flask-version.jpg)

### Step 4 - Automate Infrastructure with Terraform (IaC)

To improve reliability and save significant time, the entire infrastructure setup was automated using Terraform and deployed via GitHub Actions.

#### ✅ Terraform Scripts for EKS Cluster Creation

##### VPC with Public & Private Subnets

##### NAT Gateway for private subnets

![VPC Creation](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/VPC.jpeg)

##### EKS Cluster setup (Control Plane)

![EKS Cluster Creation](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/EKS.jpeg)

![EKS Cluster State](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/EKSCluster_creation.jpeg)

![Updating kubeconfig](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/kubeconfig.jpeg)

##### Managed Node Groups for worker nodes

![Node Group](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/Nodegroup.jpeg)

##### IAM roles for cluster and node groups

![Flask App deployment](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/flaskapp_deploy_EKS.jpeg)

##### Directory Structure:

```plaintext
terraform/
├── main.tf               # Defines VPC & EKS modules (cluster setup, networking)
├── variables.tf          # Input variables for Terraform modules
├── outputs.tf            # Outputs like VPC ID, EKS Cluster name, etc.
```

##### Example Terraform Module Configuration (EKS & VPC):

###### main.tf

```main.tf
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

  tags = {
    Environment = var.environment
  }
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

  eks_managed_node_groups = {
    flask_nodes = {
      desired_size = 2
      max_size     = 3
      min_size     = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      subnet_ids = module.vpc.private_subnets

      create_iam_role = true
      iam_role_additional_policies = {
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      }

      tags = {
        Name = "flask-node-groups"
        Environment = var.environment
      }
    }
  }
}
```

###### variables.tf

```variables.tf
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
```

###### outputs.tf

```outputs.tf
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
```

---

### ✅ GitHub Actions for Infrastructure Automation (CI/CD)

##### terraform-infra.yaml (Terraform IaC Pipeline)

```terraform-infra.yaml
name: Terraform infra Apply (Manual Approval)

on:
  workflow_dispatch:

jobs:
  terraform:
    runs-on: ubuntu-latest
    environment: Production

    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3

    - name: Set up Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.12.2

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Terraform Init
      working-directory: terraform
      run: terraform init

    - name: Terraform Plan
      working-directory: terraform
      run: terraform plan

    - name: Terraform Apply (Manual Approval Required)
      working-directory: terraform
      run: terraform apply -auto-approve
```
---
#### Terraform infrastructure automation with CICD

![Terraform infrastructure automation with CICD](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/Terra-infra.jpg)


##### deploy.yaml (CI/CD Pipeline for App Deployment)

```deploy.yaml
name: Deploy on EKS

on:
  workflow_run: 
    workflows: ["Terraform infra Apply (Manual Approval)"]
    types:
    - completed

  workflow_dispatch:
jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Code
      uses: actions/checkout@v3

    - name: Set up Docker
      uses: docker/setup-buildx-action@v2

    - name: Log in to DockerHub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD}}

    - name: Build and Push Docker image
      run: |
        docker build -t flask-docker-cicd:v2 .
        docker tag flask-docker-cicd:v2 ${{ secrets.DOCKER_USERNAME }}/flask-docker-cicd:v2
        docker push ${{ secrets.DOCKER_USERNAME }}/flask-docker-cicd:v2

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Update kubeconfig
      run: |
        aws eks update-kubeconfig --name EKSCluster --region us-east-1

    - name: Deploy to EKS
      run: |
        kubectl apply -f terraform/eks_cluster/deployment.yaml
        kubectl apply -f terraform/eks_cluster/service.yaml

    - name: Verify Deployment (Pods, Deployments, Services)
      run: |
        echo "=== Pods ==="
        kubectl get pods -o wide
        echo "=== Deployments ==="
        kubectl get deployments -o wide
        echo "=== Services ==="
        kubectl get svc -o wide
```
#### GitHub Actions to deploy Flask App on EKS Cluster

![GitHub Actions to deploy Flask App on EKS Cluster](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/flaskapp_deploy_GH.jpg)

#### Flask App deployment with output to verify endpoint

![Flask App deployment with output to verify endpoint](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/Deploy_verification.jpg)

#### EKS Cluster Creation with Terraform & GitHub Actions

![EKS Cluster Creation with Terraform & GitHub Actions](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/EKS_through_GH&Terraform.jpg)

#### Home Page

![Home Page](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/Terra_auto_homepage.jpg)

#### Health endpoint

![Health endpoint](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/Terra_auto_health.jpg)

#### Version endpoint

![Version endpoint](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/Terra_infra_version.jpg)

---

# 🕒 Manual Deployment Time Log

| Step | Task | Time Taken |
|------|------|------------|
| Step 1 | Create Flask app + health/version | 20 mins |
| Step 2 | Dockerfile creation, build, run, testing and pushed to DockerHub| 30 mins |
| Step 3 | EKS Cluster manual setup via AWS Console | 120 mins |
| Step 4 | Develop and create EKS Cluster using Terraform | 120 mins |
| Step 5 | Create GitHub Actions for EKS Cluster with terraform & deploy Flask app | 120 mins |
