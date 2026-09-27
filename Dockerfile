FROM python:3.11-slim

WORKDIR /app

# System dependencies for asyncpg and postgis
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies from the backend folder
COPY dropat_backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the actual backend code
COPY dropat_backend/ .

# Apply versioned schema changes before accepting traffic. The PORT environment
# variable is automatically injected by Railway.
CMD ["sh", "-c", "alembic upgrade head && exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
