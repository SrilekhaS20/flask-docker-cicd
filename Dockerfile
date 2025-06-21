# Use lightweight base Python image
FROM python:3.10-alpine

#Set working directory inside container
WORKDIR /app

#Copy requirements file first to leverage Docker layer caching
COPY requirements.txt .

#Install Python dependencies aithout cache (faster + smaller image)
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire app code into container
COPY . .

#Expose Flask default port
EXPOSE 5000

#Start Flask app
CMD ["python", "app.py"]