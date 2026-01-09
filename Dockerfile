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

# RUN apt-get update && apt-get install -y \
#     default-libmysqlclient-dev \
#     && rm -rf /var/lib/apt/lists/*

# Copy installed Python packages
COPY --from=builder /usr/local/lib/python3.9/site-packages \
                     /usr/local/lib/python3.9/site-packages

# Copy app source
COPY --from=builder /app /app

EXPOSE 5000

CMD ["python", "app.py"]
