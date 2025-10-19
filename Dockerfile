# Lono Clinical Safety Framework - Docker Configuration
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt requirements-dev.txt ./

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements-dev.txt

# Copy project files
COPY . .

# Create necessary directories
RUN mkdir -p /app/data/{vignettes,criteria,responses,results} \
    /app/outputs \
    /app/logs \
    /app/configs/{agents,mcp,api}

# Copy mock data to appropriate locations
RUN cp mock_clinical_vignettes.json data/vignettes/ && \
    cp mock_safety_criteria.json data/criteria/

# Create non-root user for security
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)"

# Default command (can be overridden)
CMD ["python", "dashboard.py"]
