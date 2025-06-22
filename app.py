from flask import Flask
import os
app = Flask(__name__)

@app.route("/")
def home():
    return "Flask App Deployed Manually to EKS"

@app.route("/health")
def health():
    return "OK", 200

@app.route("/version")
def version():
    try:
        with open("version.txt") as file:
            return file.read(), 200
    except:
        return "unknown", 200
    
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)