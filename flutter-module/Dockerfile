# Use Ubuntu as base image
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set up Flutter environment variables
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Clone Flutter SDK (stable branch)
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME

# Pre-download Flutter dependencies
RUN flutter precache

# Accept Android licenses (for future Android builds)
RUN yes | flutter doctor --android-licenses || true

# Run flutter doctor to verify installation
RUN flutter doctor

# Disable Flutter analytics
RUN flutter config --no-analytics

# Set working directory
WORKDIR /app

# Accept build arguments for user/group IDs
ARG USER_ID=1000
ARG GROUP_ID=1000

# Set up non-root user for development
RUN groupadd -g ${GROUP_ID} flutterdev && \
    useradd -m -u ${USER_ID} -g ${GROUP_ID} flutterdev && \
    chown -R flutterdev:flutterdev /opt/flutter && \
    chown -R flutterdev:flutterdev /app && \
    mkdir -p /home/flutterdev/.pub-cache && \
    chown -R flutterdev:flutterdev /home/flutterdev/.pub-cache

# Switch to non-root user
USER flutterdev

# Default command
CMD ["/bin/bash"]
