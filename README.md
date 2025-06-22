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

#### http://localhost:5000/ → ✅ Shows welcome message

#### http://localhost:5000/health → ✅ Returns "ok"

#### http://localhost:5000/version → ✅ Returns version from version.txt

# 🕒 Manual Deployment Time Log

| Step | Task | Time Taken |
|------|------|------------|
| Step 1 | Create Flask app + health/version | 20 mins |
| Step 2 | Dockerfile creation, build, run and testing | 30 mins |
