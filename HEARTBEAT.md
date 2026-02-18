# HEARTBEAT.md — Periodic Check-In

_Follow strictly. Do not infer tasks from prior chats._

## Rotating Check (run most overdue first)

### Production (every 30m, 6AM-6PM CT)
- Production alerts, quality flags, schedule deviations
- Messages from Seth or Bunting leadership needing response
- **Report ONLY if:** active issue, schedule miss >2h, quality hold, unanswered leadership msg

### Client Inbox (every 30m, 7AM-8PM CT)
- n0v8v client communications waiting >2h
- Deliverable deadlines within 48h
- **Report ONLY if:** client waiting, deliverable due <24h, new inquiry

### Calendar (every 2h, 7AM-9PM CT)
- Meetings within next 2h needing prep
- **Report ONLY if:** meeting <2h needs prep, conflict, missed meeting

### Tasks (every 2h, anytime)
- Stalled tasks (no progress >24h), missed commitments
- **Report ONLY if:** stalled, missed, or deadline approaching

### System (every 24h, 3AM CT)
- Agent ecosystem, n8n workflows, VPS/Docker health
- **Report ONLY if:** system down, workflow failure, error pattern

## Rules
- Nothing actionable → HEARTBEAT_OK
- Tag items: [BUNTING] [N0V8V] [PERSONAL] [SYSTEM]
- Never interrupt active subagent work
- Batch related items into one message

## FINAL STEP (always last): HEARTBEAT_OK
