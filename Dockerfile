# =========================
# Stage 1: Builder
# =========================
FROM python:3.9 AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies
COPY . .

RUN pip install --no-cache-dir --prefix=/install -r requirement.txt



# =========================
# Stage 2: Runtime
# =========================
FROM python:3.9-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the built dependencies from the builder stage
COPY --from=builder /usr/local/lib/python3.9/site-packages/ /usr/local/lib/python3.9/site-packages/

# Copy the application code from the builder stage
COPY --from=builder /app /app 
 # Expose port 5000 for the Flask application
EXPOSE 5000

# Default command (adjust as needed)
CMD ["python", "app.py"]
