# =========================
# Stage 1: Builder
# =========================
FROM python:3.9 AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY requirement.txt .

RUN pip install --no-cache-dir -r requirement.txt

COPY . .


# =========================
# Stage 2: Runtime
# =========================
FROM python:3.9-slim

WORKDIR /app

# Copy python dependencies (IMPORTANT)
COPY --from=builder /usr/local/lib/python3.9/site-packages \
                     /usr/local/lib/python3.9/site-packages

COPY --from=builder /usr/local/lib/python3.9/dist-packages \
                     /usr/local/lib/python3.9/dist-packages

# Copy app code
COPY --from=builder /app /app

EXPOSE 5000

CMD ["python", "app.py"]
