# Use official Python image
FROM python:3.10-slim

# Prevents Python from buffering stdout/stderr
ENV PYTHONUNBUFFERED=True

# Set working directory
WORKDIR /app

# Copy requirements first (Docker layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY config.py .
COPY inference.py .
COPY api_server.py .

# Create models directory and copy model
COPY models/fashionclip.simplified.onnx /app/models/

# Cloud Run provides PORT environment variable
ENV PORT=8080

# Run uvicorn server
CMD uvicorn api_server:app --host 0.0.0.0 --port ${PORT}