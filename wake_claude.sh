#!/bin/bash
set -e

# Log file for tracking executions
LOG_FILE="/app/logs/wake.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S %Z')

# Function to log to both console and file
log() {
  echo "$1" | tee -a "$LOG_FILE"
}

log "========================================="
log "[$TIMESTAMP] Starting Claude wake session..."

# Try to resume existing session, fallback to new session
if claude --continue -p "Ping: Session alive. Current time: $(date). Summarize last task if any." 2>&1 | tee -a "$LOG_FILE"; then
  log "[$TIMESTAMP] ✓ Session resumed successfully"
  exit 0
else
  log "[$TIMESTAMP] ⚠ No active session found, starting new session..."
  if claude -p "New wake session started at $(date)." 2>&1 | tee -a "$LOG_FILE"; then
    log "[$TIMESTAMP] ✓ New session created successfully"
    exit 0
  else
    log "[$TIMESTAMP] ✗ ERROR: Failed to create new session"
    exit 1
  fi
fi
