# Use a lightweight base image
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Create a non-root user
RUN useradd -m appuser

# Set work directory and permissions
WORKDIR /app
COPY app.py requirements.txt ./
COPY templates ./templates

# Change ownership to the non-root user
RUN chown -R appuser:appuser /app

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Cache busting for Docker layer caching
ARG CACHEBUST=1
RUN echo $CACHEBUST >/cachebust.txt

# Switch to the non-root user
USER appuser

# Run the app
CMD ["python", "app.py"]
