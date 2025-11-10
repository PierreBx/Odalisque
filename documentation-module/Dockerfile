# MkDocs Docker Container for Documentation Building
# Based on official Python image with MkDocs Material theme

FROM python:3.11-alpine

# Install MkDocs and required plugins
RUN pip install --no-cache-dir \
    mkdocs>=1.5.0 \
    mkdocs-material>=9.4.0 \
    mkdocstrings>=0.24.0 \
    pymdown-extensions>=10.5.0

# Install additional tools for convenience
RUN apk add --no-cache \
    bash \
    git \
    curl

# Set working directory
WORKDIR /docs

# Expose port for live server
EXPOSE 8000

# Default command - show help
CMD ["mkdocs", "--help"]
