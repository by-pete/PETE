# ref-crm — Personal CRM & Relationship Management

## Contact Intelligence System (Berman Model)
Track key contacts across both roles with relationship health scoring.

### Data Sources to Ingest
- Gmail: Email frequency, response times, tone signals
- Calendar: Meeting frequency, cancellations, no-shows
- Meeting transcripts: Action items, commitments, relationship dynamics
- LinkedIn: Engagement signals, job changes, content interactions

### Contact Record Structure
```
## [Name]
- **Role:** [Title at Company]
- **Context:** [BUNTING] / [N0V8V-CLIENT] / [N0V8V-PROSPECT] / [INDUSTRY] / [PERSONAL]
- **Relationship health:** 🟢 Active / 🟡 Cooling / 🔴 At risk
- **Last contact:** [Date]
- **Key interests:** [What they care about]
- **Communication style:** [How they prefer to interact]
- **Open items:** [What's pending between us]
- **Notes:** [Important context, preferences, history]
```

### Relationship Health Rules
- 🟢 Active: Contact within 14 days, positive engagement
- 🟡 Cooling: 15-30 days since last meaningful contact
- 🔴 At risk: 30+ days, or negative signals (delayed responses, scope reduction)

### Proactive Triggers
- Flag when key contacts go 🟡 or 🔴
- Surface relevant news about contacts' companies
- Prep context before scheduled meetings with any tracked contact
- Suggest re-engagement when relationships cool

## Prospect Pipeline (n0v8v)
- Track: Source, first contact, qualification stage, estimated MRR
- Move through: Lead → Qualified → Proposal → Negotiation → Closed
- Flag stalled prospects (>14 days in same stage)
- Monthly pipeline review with conversion metrics
