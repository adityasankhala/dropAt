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

# The PORT environment variable is automatically injected by Railway
# We use a shell form to ensure the variable expands correctly
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
