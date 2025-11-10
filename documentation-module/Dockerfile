# Typst Docker Container for Documentation Building
# Based on official Typst image

FROM ghcr.io/typst/typst:latest

# Install additional tools for convenience
RUN apk add --no-cache \
    bash \
    curl

# Set working directory
WORKDIR /docs

# Default command
CMD ["typst", "--help"]
