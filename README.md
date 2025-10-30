# Claude Wake Scheduler (No API Key)

Keeps your **Claude Code** session alive every 4 hours using the official CLI + OAuth.

## Features
- No API key needed
- OAuth login via `xvfb` (headless)
- Persistent session context
- Deployable to **Railway**, **Render**, **Fly.io**, etc.
- Local testing with Docker Compose

## Setup

1. **Clone & Push to GitHub**
   ```bash
   git clone <this-repo>
   cd claude-wake-scheduler
   git push origin main
   ```

2. **Deploy to Railway**
   - Go to [railway.app](https://railway.app)
   - New Project → Deploy from GitHub → Select this repo
   - It auto-detects `.railway.json` and sets up cron

3. **First Login (One-Time)**
   - After deploy, go to **Logs**
   - You'll see: `Open your browser and complete login...`
   - Copy the URL → open in your browser → log in with **Claude Pro/Max**
   - Container saves token in volume

4. **Done!** It will ping every 4 hours.

## Logs
- View in Railway/Render dashboard
- Local: `docker logs claude-wake`

## Notes
- Uses **Claude Code CLI** (`@anthropic-ai/claude-code`)
- Session lasts ~5 hours; 4-hour ping keeps it alive
- Pro/Max required for full Claude Code access

## How to Deploy

| Platform     | Steps |
|--------------|-------|
| **Railway**  | Push to GitHub → Import → Auto-deploys with cron |
| **Render**   | New → Background Worker → GitHub → Set cron in dashboard |
| **Fly.io**   | `flyctl launch` → add `[[services]]` cron in `fly.toml` |
| **Local**    | `docker-compose up --build` |

## First-Time Auth (Critical!)

After first deploy:
1. Open **Logs**
2. See message: `Starting OAuth login...`
3. **Copy the full URL** shown
4. Paste in your browser → log in with Claude Pro/Max
5. Token is saved permanently (in volume)

> If using **Railway**, enable **Persistent Volume**:
> - Variables → Add `RAILWAY_VOLUME_MOUNT_PATH=/root/.anthropic`

## You're Done!

Your Claude session will now:
- Wake every 4 hours
- Resume context
- Never timeout
- Work 24/7 in the cloud

---

**Push this repo to GitHub now** and deploy — zero config needed.
