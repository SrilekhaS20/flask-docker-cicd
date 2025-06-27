# Flask Docker App - Manual to CI/CD
A demo DevOps app to show how to deploy a Flask microservice to AWS EC2 using manual steps first, then automate using GitHub Actions.

## Step 1 - Run Locally (Without Docker)
Ensure Python 3.10+ is installed.
```bash
pip install -r requirements.txt
python app.py
```
#### Then visit:
#### http://localhost:5000/ → ✅ Shows welcome message

#### http://localhost:5000/health → ✅ Returns "ok"

#### http://localhost:5000/version → ✅ Returns version from version.txt

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
```
# Build the image
docker build -t flask-docker-cicd:v1 .

# Run the container
docker run -p 5000:5000 flask-docker-cicd:v1
```

---

✅ Verify App in Browser

#### Visit the following URLs in your browser (while the container is running):

##### http://localhost:5000/ → ✅ Shows welcome message

![Home Page] (screenshots/browser-homepage.jpg)

##### http://localhost:5000/health → ✅ Returns "ok"

##### http://localhost:5000/version → ✅ Returns version from version.txt

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
kubectl get deploy
```

### Step 3.8 – Get Load Balancer IP

```bash
kubectl get svc flask-service
```

#### Access your Flask app in browser using EXTERNAL-IP of LoadBalancer


🌐 App Access

Once deployment is successful, open your browser:

```bash
http://<LoadBalancer-External-IP>
http://<LoadBalancer-External-IP>/health
http://<LoadBalancer-External-IP>/version
```

# 🕒 Manual Deployment Time Log

| Step | Task | Time Taken |
|------|------|------------|
| Step 1 | Create Flask app + health/version | 20 mins |
| Step 2 | Dockerfile creation, build, run, testing and pushed to DockerHub| 30 mins |
| Step 3 | EKS Cluster manual setup via AWS Console | 120 mins |
