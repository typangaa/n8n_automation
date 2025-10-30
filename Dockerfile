# Use Ubuntu 22.04 for stability and easy package management
FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install essentials + Node.js 20 + curl
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      gnupg \
      cron \
      xvfb \
      && rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Create app directory
WORKDIR /app

# Copy scripts
COPY wake_claude.sh entrypoint.sh crontab ./

# Make scripts executable
RUN chmod +x wake_claude.sh entrypoint.sh

# Install crontab
RUN crontab crontab

# Expose nothing (headless)
EXPOSE 3000

# Run entrypoint
CMD ["/app/entrypoint.sh"]
