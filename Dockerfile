# Build stage
FROM python:3.10-slim-bookworm as builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    gfortran \
    libopenblas-dev \
    liblapack-dev \
    pkg-config \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Create and activate virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python packages
RUN pip install --no-cache-dir \
    wheel \
    setuptools \
    numpy \
    && pip install --no-cache-dir \
    scipy \
    pandas \
    matplotlib \
    statsmodels \
    mageck

# Final stage
FROM python:3.10-slim-bookworm

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application
COPY . /app
WORKDIR /app

RUN python setup.py install

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["mageck", "--version"]