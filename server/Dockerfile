# Use official Python image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies if any (e.g., for opencv)
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install python dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir gunicorn

# Copy application code
COPY . .

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Expose port 7860 (Hugging Face Spaces default)
ENV PORT=7860
EXPOSE 7860

# Run with Gunicorn
# Timeout set to 120s because ML operations can be slow
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 120 app:app
