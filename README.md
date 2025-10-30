# Claude Wake Scheduler with n8n (Adelaide Timezone)

Automated **Claude Code** session keeper using **n8n workflow automation** with native Adelaide timezone support.

## Features

- **Visual Workflow Scheduling** - n8n's Schedule Trigger (no cron needed)
- **Adelaide Timezone Native** - Runs at 6:30 AM, 11:30 AM, 4:30 PM, 9:30 PM Adelaide time
- **Telegram Notifications** - Instant alerts when wake fails
- **Execution Logging** - Track every wake attempt with timestamps
- **No API Key Required** - Uses Claude OAuth authentication
- **Persistent Sessions** - Resumes context across wakes
- **Easy Monitoring** - n8n UI shows execution history

## Architecture

```
n8n Workflow
├─ Schedule 6:30 AM  ─┐
├─ Schedule 11:30 AM ─┤
├─ Schedule 4:30 PM  ─┼─→ Execute wake_claude.sh ─→ Check Exit Code
└─ Schedule 9:30 PM  ─┘            ↓                         ↓
                                Success                   Error
                                   ↓                         ↓
                              Log Execution        Send Telegram Alert
                                                   + Log Execution
```

## Quick Start

### 1. Deploy to Railway

```bash
# This repo is already initialized and pushed to:
# https://github.com/typangaa/n8n_automation.git

# Go to Railway and deploy:
# 1. Visit https://railway.app
# 2. New Project → Deploy from GitHub
# 3. Select typangaa/n8n_automation
# 4. Wait for initial deployment to complete
```

**Step 1: Generate Public Domain**

IMPORTANT: Do this FIRST before adding environment variables!

1. Go to your Railway project → Service → **Settings**
2. Click **Generate Domain** (under Networking)
3. Copy the generated URL (e.g., `https://n8n-production-9d52.up.railway.app`)

**Step 2: Add Environment Variables**

Go to **Variables** tab and add these (replace `your-app.up.railway.app` with YOUR actual Railway URL from Step 1):

```env
# n8n Public URL Configuration (CRITICAL!)
WEBHOOK_URL=https://your-app.up.railway.app/
N8N_EDITOR_BASE_URL=https://your-app.up.railway.app
N8N_PROTOCOL=https
N8N_HOST=your-app.up.railway.app

# Authentication (CHANGE THE PASSWORD!)
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your-secure-password-here

# Timezone
GENERIC_TIMEZONE=Australia/Adelaide
TZ=Australia/Adelaide

# Optional: Security
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
```

**Step 3: Redeploy**

After adding variables:
- Click **Deploy** → **Redeploy** (or Railway will auto-redeploy)
- Wait for deployment to complete
- Access n8n at your Railway URL

### 2. Import Workflow to n8n

After deployment completes:

1. Open your n8n instance: `https://your-app.up.railway.app`
2. Login with credentials (admin / your-password)
3. Go to **Workflows** → Click **"Import from File"**
4. Upload `n8n-workflow.json` from this repo
5. The workflow will appear with 4 schedule nodes

### 3. Configure Telegram Notifications

**Create Telegram Bot:**

1. Open Telegram → search for `@BotFather`
2. Send `/newbot` → follow prompts → save the **Bot Token**
3. Start a chat with your new bot
4. Get your Chat ID:
   - Open `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
   - Send a message to your bot
   - Refresh the URL → find `"chat":{"id": 123456789}`
   - Save the Chat ID

**Add to n8n:**

1. In n8n, go to **Credentials** → **Add Credential**
2. Select **Telegram API**
3. Name: `Telegram Bot`
4. Enter your Bot Token
5. Save

**Update Workflow:**

1. Open the imported workflow
2. Click on **"Send Telegram Alert"** node
3. Update `chatId` parameter with your Chat ID
4. Click **Save**

### 4. Authenticate Claude (One-Time)

**Option A: Railway Shell (Recommended)**

1. Go to Railway → Your Project → Click on Service
2. Open **Terminal** tab
3. Run:
   ```bash
   cd /app
   xvfb-run claude
   ```
4. Copy the OAuth URL shown
5. Open in browser → login with Claude Pro/Max
6. Token is saved to persistent volume

**Option B: Local Authentication (Then Push Volume)**

```bash
# Run locally first
docker-compose up -d
docker exec -it n8n-claude-wake bash
xvfb-run claude
# Complete auth in browser
# Token is saved to ./claude-auth volume
```

### 5. Activate Workflow

1. In n8n, open the workflow
2. Click **"Activate"** toggle (top right)
3. Status changes to **Active** ✅

**Test Immediately:**

- Click on **"Wake Claude"** node
- Click **"Execute Node"** at bottom
- Check output in execution panel
- Verify log file: `/app/logs/wake.log`

## Local Development

```bash
# Clone the repo
git clone https://github.com/typangaa/n8n_automation.git
cd n8n_automation

# Start n8n + Claude
docker-compose up --build

# Access n8n UI
open http://localhost:5678

# Login: admin / changeme123

# Import workflow
# Upload n8n-workflow.json

# Authenticate Claude (in container shell)
docker exec -it n8n-claude-wake bash
xvfb-run claude
```

## Monitoring & Logs

### n8n Execution History

- Go to **Executions** tab in n8n
- View all past wake attempts with timestamps
- Green = Success, Red = Error
- Click any execution to see full output

### Log Files

**n8n Execution Log:**
```bash
# Inside container or Railway shell
cat /app/logs/n8n-executions.log
```

**Wake Script Log:**
```bash
cat /app/logs/wake.log
```

**Local Development:**
```bash
# Logs are mounted to ./logs/ directory
cat logs/wake.log
cat logs/n8n-executions.log
```

### Telegram Alerts

When a wake fails, you'll receive:
```
⚠️ Claude Wake Failed at 2025-10-30 14:30:00

❌ Error: [Error message from stderr]

📋 Exit Code: 1

🔍 Check logs: /app/logs/wake.log
```

## Schedule Details

All times in **Australia/Adelaide** (handles DST automatically):

| Time      | Cron Expression | DST Aware |
|-----------|----------------|-----------|
| 6:30 AM   | `30 6 * * *`   | ✅        |
| 11:30 AM  | `30 11 * * *`  | ✅        |
| 4:30 PM   | `30 16 * * *`  | ✅        |
| 9:30 PM   | `30 21 * * *`  | ✅        |

n8n automatically adjusts for daylight saving time changes.

## Troubleshooting

### n8n Shows "localhost:5678" Instead of Railway URL

**Symptom:** n8n displays `Editor is now accessible via: http://localhost:5678` instead of your Railway public URL

**Solution:**

1. **Check Environment Variables** in Railway dashboard:
   ```bash
   # These MUST be set with your actual Railway URL:
   WEBHOOK_URL=https://n8n-production-9d52.up.railway.app/
   N8N_EDITOR_BASE_URL=https://n8n-production-9d52.up.railway.app
   N8N_PROTOCOL=https
   N8N_HOST=n8n-production-9d52.up.railway.app
   ```

2. **Verify Railway Generated Domain:**
   - Go to Settings → Networking
   - Ensure domain is generated (not disabled)
   - Copy the exact URL

3. **Update Variables:**
   - Replace all instances of `localhost:5678` with your Railway URL
   - Remove `N8N_PORT=5678` if present (Railway auto-assigns PORT)
   - Remove `N8N_HOST=0.0.0.0` if present

4. **Redeploy:**
   - Save variables
   - Deploy → Redeploy
   - Check logs for: `Editor is now accessible via: https://your-app.up.railway.app`

**Common Mistakes:**
- ❌ Forgot trailing slash in `WEBHOOK_URL` (should be `...app/`)
- ❌ Used `http://` instead of `https://`
- ❌ Set `N8N_HOST=0.0.0.0` (this forces localhost mode)
- ❌ Didn't redeploy after changing variables

### Claude Authentication Fails

**Symptom:** `No anthropic credentials found`

**Solution:**
```bash
# In Railway shell or local container:
xvfb-run claude
# Complete OAuth in browser
```

### Telegram Not Sending

**Check:**
1. Telegram credentials added to n8n? (Credentials tab)
2. Chat ID correct in workflow node?
3. Bot token valid?
4. Did you start a chat with the bot first?

### Wake Script Fails

**Check logs:**
```bash
cat /app/logs/wake.log
```

**Common issues:**
- Claude CLI not installed: Check Dockerfile build logs
- xvfb missing: Ensure `RUN apk add --no-cache xvfb` in Dockerfile
- Token expired: Re-authenticate with `xvfb-run claude`

### Railway Deployment Errors

#### "The train has not arrived at the station"

**Symptom:** Railway shows "Not Found" or "Train has not arrived" error when accessing URL

**Causes & Solutions:**

1. **Container not starting properly**
   ```bash
   # Check Railway logs:
   # 1. Go to Railway → Your Project → Deployments
   # 2. Click on latest deployment → View Logs
   # 3. Look for error messages
   ```

2. **Missing environment variables**
   - Verify all required variables are set (see .env.example)
   - Especially check: `WEBHOOK_URL`, `N8N_EDITOR_BASE_URL`, `N8N_PROTOCOL`

3. **Build failed**
   - Check Build Logs tab for errors
   - Common issue: npm install timeout (try redeploying)
   - Docker build error (check Dockerfile syntax)

4. **Health check failing**
   - n8n takes 30-60 seconds to start
   - Wait 2-3 minutes after deployment
   - Check logs for "Editor is now accessible via..."

5. **Port binding issue**
   - Railway auto-assigns PORT variable
   - **Do NOT** set `N8N_PORT` or `PORT` manually
   - n8n will automatically use Railway's PORT

6. **Domain not provisioned yet**
   - After generating domain, wait 2-5 minutes
   - Try regenerating domain (Settings → Networking → Generate Domain)
   - Clear browser cache and try again

**Quick Fix Steps:**
```bash
1. Delete all environment variables in Railway
2. Re-add only these:
   - N8N_BASIC_AUTH_ACTIVE=true
   - N8N_BASIC_AUTH_USER=admin
   - N8N_BASIC_AUTH_PASSWORD=your-password
   - GENERIC_TIMEZONE=Australia/Adelaide
   - TZ=Australia/Adelaide
3. DO NOT set: N8N_HOST, N8N_PORT, PORT
4. Redeploy
5. Wait 3 minutes
6. Access Railway URL
```

#### n8n Container Crashes on Startup

**Check Railway logs:**
- Port binding error? Remove `N8N_PORT` env var (Railway handles this)
- Database migration error? Check n8n version compatibility
- Permission error? Check file ownership in Dockerfile

**Common fixes:**
- Restart deployment (Deploy → Redeploy)
- Clear build cache (Settings → Clear Cache)
- Check for conflicting environment variables

## File Structure

```
n8n_automation/
├── Dockerfile              # n8n + Claude CLI + xvfb
├── wake_claude.sh          # Wake script with logging
├── n8n-workflow.json       # Importable workflow (4 schedules)
├── docker-compose.yml      # Local testing setup
├── .railway.json           # Railway deployment config (deprecated, use railway.toml)
├── railway.toml            # Railway configuration with health checks
├── .env.example            # Environment variables reference
└── README.md               # This file
```

## Environment Variables Reference

### Required for Railway

```env
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=changeme123
GENERIC_TIMEZONE=Australia/Adelaide
TZ=Australia/Adelaide
```

### Optional

```env
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=https                    # If using custom domain with SSL
WEBHOOK_URL=https://your-domain.com   # For webhook triggers
```

## Customization

### Change Schedule Times

1. Open workflow in n8n
2. Click on any Schedule node
3. Modify **Cron Expression** or use visual editor
4. Click **Save**

### Add More Actions

n8n makes it easy to extend:

- **Add Slack notifications:** Insert Slack node after wake
- **Log to database:** Add PostgreSQL/MySQL node
- **Daily summary email:** Add new schedule + email node
- **Webhook trigger:** Add webhook node for manual wake

### Change Timezone

Update environment variables:
```env
GENERIC_TIMEZONE=America/New_York
TZ=America/New_York
```

Then update cron expressions in n8n workflow.

## Cost Estimates

| Service          | Cost/Month | Notes                           |
|------------------|------------|---------------------------------|
| Railway (Hobby)  | $5-10      | 500 hours included, then $0.02/hr |
| Render (Starter) | $7         | Always-on service               |
| n8n Cloud        | $20        | Hosted n8n (no Docker needed)   |
| **Self-Hosted**  | **$5-10**  | **Recommended for this setup**  |

## Security Notes

- **Change default password** in `N8N_BASIC_AUTH_PASSWORD`
- **Use Railway secrets** for sensitive env vars
- **Enable 2FA** on your Railway/GitHub accounts
- **Don't commit** `.env` files with real credentials
- **Claude token** is stored in encrypted volume

## Support & Contributing

- **Issues:** https://github.com/typangaa/n8n_automation/issues
- **n8n Docs:** https://docs.n8n.io
- **Claude Code:** https://docs.claude.com/claude-code

## License

MIT - Feel free to modify and use commercially.

---

**Ready to deploy?** Push to GitHub and deploy on Railway in 5 minutes!
