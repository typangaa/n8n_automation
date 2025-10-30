# Use official n8n base image
FROM n8nio/n8n:latest

# Switch to root to install system packages
USER root

# Install xvfb and bash for headless Claude OAuth authentication
RUN apk add --no-cache \
    xvfb \
    xvfb-run \
    bash \
    && rm -rf /var/cache/apk/*

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Create app directory and logs directory
RUN mkdir -p /app/logs && chown -R node:node /app

# Copy scripts
COPY wake_claude.sh /app/
RUN chmod +x /app/wake_claude.sh && chown node:node /app/wake_claude.sh

# Switch back to node user (n8n default)
USER node

# Set working directory back to n8n's default
WORKDIR /home/node

# Expose n8n default port
EXPOSE 5678

# Use n8n's original entrypoint (don't override CMD)
# The base image already has the correct ENTRYPOINT and CMD
