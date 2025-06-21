# Flask Docker App - Manual to CI/CD
A demo DevOps app to show how to deploy a Flask microservice to AWS EC2 using manual steps first, then automate using GitHub Actions.

## Run Locally (Without Docker)
Ensure Python 3.10+ is installed.
```bash
pip install -r requirements.txt
python app.py
```
Then visit:
http://localhost:5000/
http://localhost:5000/health
http://localhost/version

### Version
v1.0.0 - Manual setup base version

# 🕒 Manual Deployment Time Log

| Step | Task | Time Taken |
|------|------|------------|
| Step 1 | Create Flask app + health/version | 20 mins |
