# Use a lightweight official Python image
FROM python:3.13-bookworm AS base

WORKDIR /app

COPY . .

# Prevent Python from writing pyc files & enable unbuffered output
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create virtual environment
RUN python -m venv venv

# Set PATH so Python and pip use the virtualenv
ENV PATH="/app/venv/bin:$PATH"

# Install dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt
RUN rm requirements.txt

FROM python:3.13-slim-bookworm AS final

# Create a non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup -m appuser

# Update OS
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y upgrade && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER appuser

# Copy from base
COPY --chown=appuser:appgroup --from=base /app /app/

# Set PATH so Python uses the virtualenv
ENV PATH="/app/venv/bin:$PATH"

WORKDIR /app

# Expose the Flask port
EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
