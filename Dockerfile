# Build Stage
FROM python:3.10-alpine as builder

#Set working directory inside container
WORKDIR /app

# Copy only requirements first (to cache better)
RUN apk update && apk add --no-cache gcc musl-dev libffi-dev

#Copy requirements file first to leverage Docker layer caching
COPY requirements.txt .

#Install Python dependencies in a separate directory
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Copy the entire app code into container
COPY . .

# Final minimal Runtime Stage
FROM python:3.10-alpine

WORKDIR /app

# Copy installed dependencies from builder
COPY --from=builder /install /usr/local

# Copy only app code
COPY --from=builder /app /app

#Expose Flask default port
EXPOSE 5000

#Start Flask app
CMD ["python", "app.py"]