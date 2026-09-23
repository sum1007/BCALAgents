## Workflow — Dynamics 365 Business Central (AL)

Defines the end-to-end flow the orchestrator drives and the gates between phases.

### Flow Overview
```
User request
   ├─ Planning Gate ──(≥2 verbs OR ≥2 AL object types OR sequencing OR multi-subagent)──► call plan FIRST
   ├─ Routing (Binary Branch)
   │     Template name / "from template" ─► Resource branch (BC Resource Reuse | BC Integration Generation)
   │     else                             ─► Basic branch    (BC AL Generation Assistant)
   ├─ Creation sub-agent runs → emits Handoff Contract
   ├─ Post-Creation Verification (orchestrator-owned, READ-ONLY gate)
   └─ BC Build & Publish Assistant → compile + publish + cop fixes
```

### Phase 0 — Planning (conditional)
Trigger per copilot-instructions.md §Planning Gate. If triggered, call the plan tool BEFORE any run_subagent. If a plan exists → follow it.

### Phase 1 — Creation (delegated)
Orchestrator resolves the agent from Agent Map (exact display name) and calls run_subagent. Sub-agent creates `.al` under `src/` and returns the Handoff Contract.

### Phase 2 — Post-Creation Verification (ORCHESTRATOR-OWNED, READ-ONLY)
Run after every creation branch, BEFORE handing to BC Build & Publish Assistant. Read-only tools only (Test-Path, grep_search/Select-String, get_file). No writes.

Checklist (ALL must pass):
1. **File existence** — each `changedFiles[].path`: `Test-Path <appSourcePath>/<path>` = True.
2. **Object header matches type** — `Select-String` for declared `objectType` keyword + object number.
3. **Affix present** — object name AND every new field/control/action starts with `{PREFIX}`.
4. **ID in range** — every `objectId` inside `{ObjectIdRange}`; no duplicate vs the Ledger.
5. **No scaffold leftovers** — grep `MyTable`/`MyPage`/`MyField`/`PLACEHOLDER` → ZERO matches.
6. **Captions/ToolTips** — new controls have `Caption` (+ `ToolTip` on Pages).
7. **PermissionSet coverage** — functional object created → a PermissionSet references it or is in changedFiles.

Result: ALL pass → Phase 3. ANY fail → route back to the creation sub-agent with the failing item(s). Do NOT fix from the orchestrator.

### Phase 3 — Build & Publish (delegated to BC Build & Publish Assistant)
- Phase 0 is the ONLY writer of app.json (version bump, idRanges widen, dependency add).
- Compile → resolve cop findings (max 3). Publish to sandbox (max 3 build attempts). On failure → consult error-library, surface to user. Emit build summary + timing (UTC+7).

### Gate Ownership Summary
| Gate / Phase | Owner | Write allowed? |
|---|---|---|
| Planning | Orchestrator (plan tool) | plan file only |
| Creation | Creation sub-agent | Yes — .al under src/ |
| Post-Creation Verification | Orchestrator | NO (read-only) |
| app.json mutation | BC Build & Publish Assistant Phase 0 | Yes — app.json only |
| Build / Publish / Cop fixes | BC Build & Publish Assistant | Yes — .al + app.json |
