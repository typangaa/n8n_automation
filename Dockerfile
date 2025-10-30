# Use official n8n base image
FROM n8nio/n8n:latest

# Switch to root to install system packages
USER root

# Install xvfb for headless Claude OAuth authentication
RUN apk add --no-cache xvfb xvfb-run

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Create app directory and logs directory
WORKDIR /app
RUN mkdir -p /app/logs

# Copy scripts
COPY wake_claude.sh ./
RUN chmod +x wake_claude.sh

# Switch back to node user (n8n default)
USER node

# Expose n8n default port
EXPOSE 5678

# Use n8n's default entrypoint
CMD ["n8n", "start"]
