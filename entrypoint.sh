#!/bin/bash
set -e

# First-time authentication (only runs if no token exists)
if [ ! -f "/root/.anthropic/credentials" ]; then
  echo "No Claude credentials found. Starting OAuth login..."
  echo "Open your browser and complete login at the URL below:"
  xvfb-run --server-args="-screen 0 1024x768x24" claude
  echo "Authentication complete. Token saved."
else
  echo "Claude already authenticated."
fi

# Start cron daemon in background
service cron start

# Keep container alive and show logs
echo "Cron scheduler started. Waking every 4 hours..."
tail -f /var/log/cron.log 2>/dev/null || tail -f /dev/null
