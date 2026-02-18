# DEPLOY.md — OpenClaw Production Deployment Guide

## Architecture: Tiny Input, Rich Output

The #1 cost driver in OpenClaw is **input tokens** — your workspace files (SOUL.md, AGENTS.md, USER.md, MEMORY.md) get injected into EVERY prompt. A simple "what's the weather" costs 8-15K input tokens just from context injection.

### The Fix: Reference File Architecture

```
workspace/
├── SOUL.md          (~200 tokens)  ← Injected every request
├── AGENTS.md        (~250 tokens)  ← Injected every request  
├── USER.md          (~200 tokens)  ← Injected every request
├── IDENTITY.md      (~200 tokens)  ← Injected every request
├── HEARTBEAT.md     (~300 tokens)  ← Injected on heartbeat only
├── MEMORY.md        (~300 tokens)  ← Injected every request
├── TOOLS.md         (optional)     ← Injected every request
└── memory/                         ← VECTORIZED, searched on-demand
    ├── ref-clients.md              ← Only loaded when client work happens
    ├── ref-bunting.md              ← Only loaded when Bunting context needed
    ├── ref-content.md              ← Only loaded when content work happens
    ├── ref-briefing.md             ← Only loaded by cron jobs
    ├── ref-security.md             ← Only loaded for security tasks
    ├── ref-crm.md                  ← Only loaded for relationship management
    ├── 2026-02-18.md               ← Auto-generated daily memory files
    └── ...
```

**Before this architecture:** ~3,000-14,000 tokens of context injected every request
**After:** ~1,150 tokens injected + on-demand retrieval from vectorized memory

**Cost impact at Sonnet rates ($3/1M input):**
- Old way: 14K tokens × 100 requests/day = 1.4M tokens = $4.20/day
- New way: 1.15K tokens × 100 requests/day = 115K tokens = $0.35/day
- **Savings: ~$115/month on input alone**

The key insight from the community: **Move instructions from personality .md files into skills and reference files.** Skills only load when invoked. Reference files only load when memory_search finds them relevant.

## Deployment Steps

### Step 1: Copy workspace files into your OpenClaw container
```bash
# Find your workspace path
docker compose exec openclaw find / -name "SOUL.md" -o -name "workspace" -type d 2>/dev/null

# Typical paths:
# /data/workspace/
# /root/.openclaw/workspace/
# ~/.openclaw/workspace/

# Copy files (adjust path as needed)
WORKSPACE="/data/workspace"  # or wherever yours is

docker cp workspace/SOUL.md <container>:$WORKSPACE/SOUL.md
docker cp workspace/AGENTS.md <container>:$WORKSPACE/AGENTS.md
docker cp workspace/USER.md <container>:$WORKSPACE/USER.md
docker cp workspace/MEMORY.md <container>:$WORKSPACE/MEMORY.md
docker cp workspace/HEARTBEAT.md <container>:$WORKSPACE/HEARTBEAT.md

# Copy reference files into memory directory
docker exec <container> mkdir -p $WORKSPACE/memory
docker cp workspace/memory/ref-clients.md <container>:$WORKSPACE/memory/
docker cp workspace/memory/ref-bunting.md <container>:$WORKSPACE/memory/
docker cp workspace/memory/ref-content.md <container>:$WORKSPACE/memory/
docker cp workspace/memory/ref-briefing.md <container>:$WORKSPACE/memory/
docker cp workspace/memory/ref-security.md <container>:$WORKSPACE/memory/
docker cp workspace/memory/ref-crm.md <container>:$WORKSPACE/memory/
```

### Step 2: Apply config
```bash
# Copy openclaw.json (adjust comments — JSON5 may or may not be supported)
docker cp openclaw.json <container>:/root/.openclaw/openclaw.json
# OR
docker cp openclaw.json <container>:/data/.openclaw/openclaw.json

# Restart to pick up config
docker compose restart openclaw
```

### Step 3: Verify memory vectorization
```bash
# Check if sqlite-vec is available (enables fast vector search)
docker compose exec openclaw openclaw doctor

# Check memory index status
docker compose exec openclaw openclaw memory status

# Force re-index if needed
docker compose exec openclaw openclaw memory reindex
```

### Step 4: Set up cron jobs
```bash
# Copy and run the cron setup script
docker cp setup-crons.sh <container>:/tmp/setup-crons.sh
docker compose exec openclaw bash /tmp/setup-crons.sh

# Verify
docker compose exec openclaw openclaw cron list
```

### Step 5: Test
```bash
# Test agent identity
openclaw agent --message "Who are you and what do you know about me?"

# Test memory search
openclaw agent --message "What are my client management procedures?"

# Test heartbeat
openclaw system event --text "Test heartbeat" --mode now

# Check token usage
# In chat: /status
# In chat: /usage full
```

## Token Optimization Checklist

- [x] Lean workspace files (<1,200 tokens total for always-injected files)
- [x] Reference files in memory/ (vectorized, on-demand only)
- [x] Context pruning enabled (cache-ttl, 4h)
- [x] Compaction with memory flush (35K token threshold)
- [x] Cheap embeddings (text-embedding-3-small)
- [x] Hybrid search with MMR dedup and temporal decay
- [x] Sonnet as default (Opus only when explicitly needed)
- [x] Haiku for monitoring/heartbeat agent
- [x] Cron jobs use isolated sessions (no main session context bleed)
- [x] Heartbeat active hours restricted (6AM-10PM)
- [x] Image dimensions capped at 1024px

## Berman Feature Map — What's Implemented

| Berman Feature | Status | How |
|---|---|---|
| Identity/Soul | ✅ | SOUL.md + IDENTITY.md |
| Evolving Memory | ✅ | Vectorized memory/ + compaction flush |
| Personal CRM | ✅ ref | ref-crm.md + cron health checks |
| Knowledge Base | ✅ ref | Drop URLs → ingest → vectorize → query |
| Business Advisory Council | 🔲 Phase 2 | Multiple named agents with overnight analysis |
| Content Pipeline | ✅ ref | ref-content.md + cron triggers |
| Security Council | ✅ ref | ref-security.md + weekly audit cron |
| Automated Backups | ✅ cron | Daily git backup cron |
| Health Tracking | 🔲 Optional | Can add as memory/health-log.md |
| Morning Briefing | ✅ cron | Isolated session cron at 6AM CT |

## Cost Monitoring

```bash
# In chat
/status              # Current session tokens + cost
/usage full          # Per-response token footer
/usage cost          # Local cost summary from logs

# CLI
openclaw status --usage

# Provider dashboards
# Anthropic: https://console.anthropic.com/settings/usage
# OpenAI: https://platform.openai.com/usage
# OpenRouter: https://openrouter.ai/activity
```

## Emergency Controls

```bash
# Kill heartbeats if costs spike
openclaw config patch '{"agents.defaults.heartbeat.every": "0m"}'

# Switch everything to Haiku immediately
openclaw config patch '{"agents.defaults.model.primary": "anthropic/claude-haiku-4-5"}'

# Disable all cron jobs
openclaw cron disable --all

# Nuclear: reset session to clear context bloat
openclaw session reset
```
