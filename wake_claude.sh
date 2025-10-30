#!/bin/bash
set -e

echo "[$(date)] Waking Claude session..."

# Use --continue to resume last session, or start new if none
claude --continue -p "Ping: Session alive. Current time: $(date). Summarize last task if any." \
  || claude -p "New wake session started at $(date)."

echo "[$(date)] Wake complete."
