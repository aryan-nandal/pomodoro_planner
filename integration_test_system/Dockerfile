FROM debian:bookworm-slim

# Avoid interactive prompts during apt install
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies to add external repositories
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Add Adoptium (Eclipse Temurin) repository for Java 21
RUN mkdir -p /etc/apt/keyrings && \
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bookworm main" | tee /etc/apt/sources.list.d/adoptium.list

# Install core system dependencies, Chromium and Java 21
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    temurin-21-jdk \
    rsync \
    chromium \
    chromium-driver \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js v20 (needed for Firebase Tools and Database Seeder)
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Firebase CLI globally
RUN npm install -g firebase-tools

# Pre-download Firebase Emulator binaries (Firestore) to prevent runtime download timeout
RUN firebase setup:emulators:firestore

# Set Chrome executable environment variable for Flutter Web testing
ENV CHROME_EXECUTABLE=/usr/bin/chromium

# Install Flutter SDK (stable branch)
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin

RUN git clone https://github.com/flutter/flutter.git -b stable ${FLUTTER_HOME}

# Pre-download Flutter development binaries, enable Web platform, and cache dependencies
RUN flutter config --enable-web && \
    flutter doctor -v

# Set up working directory inside the container
WORKDIR /workspace

# Default entrypoint
ENTRYPOINT ["/bin/bash"]
