# Use official Python base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy your Python script
COPY CICD_Pipeline.py .

# Run the script on container start
CMD ["python", "CICD_Pipeline.py"]
