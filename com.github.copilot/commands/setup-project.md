---
name: setup-project
description: Bootstrap the D365 BC AL orchestrator — reads app.json + ruleset and populates app-analysis §Quick Reference, ID Allocation Ledger, and the Agent Map.
---

## /setup-project — Bootstrap the D365 BC AL orchestrator

Run this once per repository (and after any app.json change) so the orchestrator and sub-agents can resolve
`{PREFIX}`, `{ObjectIdRange}`, `{AppName}`, dependencies, and the Agent Map without guessing.

### Steps
1. **Locate app.json** at the app root (read-only). If none → tell the user this is not an AL app root and stop.
2. **Read app.json** fields: `name`, `publisher`, `version`, `idRanges` (from/to), `application`, `runtime`, `dependencies`.
3. **Resolve the affix** from the AppSourceCop ruleset / `AppSourceCop.json` `mandatoryAffixes`. If absent → ask the user for the registered affix; do NOT invent one.
4. **Populate** instructions/model/app-analysis.instructions.md:
   - §Quick Reference — {PREFIX}, {AppName}, {Publisher}, {ObjectIdRange}, {AppVersion}, runtime/application, default language.
   - §ID Allocation Ledger — split the licensed range into per-object sub-ranges; set each "Next free" to the lowest free ID (scan existing `src/**/*.al` for used IDs).
   - §Agent Map — confirm the 4 display names match agents/ files.
5. **Sync** the §Agent Map in instructions/copilot-instructions.md with the model file.
6. **Report** a short summary table of resolved values and flag any `<placeholder>` still unresolved.

### Guardrails
- Read-only for app.json/ruleset in this command (no mutation). Only the app-analysis + copilot-instructions markdown are updated.
- NEVER fabricate an affix or an ID range. Unknown → ask the user.
- Do NOT run any sub-agent from setup; this only populates configuration.

### Output
A confirmation table: PREFIX, AppName, Publisher, ObjectIdRange, AppVersion, dependencies count, and "Ledger initialized: yes/no".
