#!/bin/bash
# =============================================
# OPENCLAW CRON SETUP — Run after gateway is up
# =============================================

# Morning Briefing — Daily at 6:00 AM CT (12:00 UTC in winter)
openclaw cron add --json '{
  "name": "morning-briefing",
  "schedule": "0 12 * * *",
  "enabled": true,
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "deliver": true,
    "channel": "discord",
    "message": "Run the morning briefing. Search memory for ref-briefing and follow that format exactly. Check calendar, email, and pending tasks. Keep it under 300 words."
  }
}'

# Weekly Digest — Sunday at 7:00 PM CT (01:00 UTC Monday)
openclaw cron add --json '{
  "name": "weekly-digest",
  "schedule": "0 1 * * 1",
  "enabled": true,
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "deliver": true,
    "channel": "discord",
    "message": "Run the weekly digest. Search memory for ref-briefing for the weekly format. Summarize this weeks accomplishments, open items, client pipeline, and next weeks critical dates."
  }
}'

# Security Audit — Weekly, Wednesday at 3:00 AM CT (09:00 UTC)
openclaw cron add --json '{
  "name": "security-audit",
  "schedule": "0 9 * * 3",
  "enabled": true,
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "deliver": true,
    "channel": "discord",
    "message": "Run security audit. Search memory for ref-security. Run openclaw doctor and openclaw security audit --deep. Report any findings. If clean, just say Security: All clear."
  }
}'

# Client Health Check — Every weekday at 4:00 PM CT (22:00 UTC)
openclaw cron add --json '{
  "name": "client-health-check",
  "schedule": "0 22 * * 1-5",
  "enabled": true,
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "deliver": true,
    "channel": "discord",
    "message": "Check client health. Search memory for ref-crm and ref-clients. Flag any relationships going yellow or red, pending deliverables due within 48 hours, or unanswered client communications. If all clear, say Clients: All current."
  }
}'

# Knowledge Base Backup — Daily at 2:00 AM CT (08:00 UTC)
openclaw cron add --json '{
  "name": "backup-memory",
  "schedule": "0 8 * * *",
  "enabled": true,
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "deliver": false,
    "message": "Run git add -A && git commit -m \"daily-backup-$(date +%Y-%m-%d)\" && git push in the workspace directory. If git is not configured, skip silently."
  }
}'

echo "✅ Cron jobs configured. Verify with: openclaw cron list"
