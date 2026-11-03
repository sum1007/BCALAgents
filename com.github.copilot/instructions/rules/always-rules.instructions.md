## Always-On Rules — Dynamics 365 Business Central (AL)

Non-negotiable rules applied to EVERY Copilot interaction. Sections referenced by number from copilot-instructions.md.

### 1. Language
- Reply in the user's language (VN/EN). ALL generated content (AL code, captions, labels, comments, tooltips) is **English only**.

### 2. Object Affix / Prefix (AppSource — HARD)
- EVERY new object, field, control, action, key, and enum value MUST carry the registered `{PREFIX}` affix.
- `{PREFIX}` comes from app-analysis §Quick Reference — NEVER invent it, NEVER copy `YVS`. Enforced by AppSourceCop.

### 3. Object IDs
- New IDs MUST fall inside `{ObjectIdRange}`. Use next free from the ID Allocation Ledger — NEVER hardcode from an example. Update the Ledger after each creation.

### 4. Compatibility & Standards
- No breaking changes to published schema (obsoletion: `ObsoleteState = Pending` → `Removed`).
- Prefer `TableExtension`/`PageExtension`/`EnumExtension` over touching base objects (base app is never editable).
- Use extensible `Enum` instead of `Option`. Business logic in Codeunits; integrate via event subscribers.

### 5. AL Commenting Best Practices
- Add `/// <summary>` XML documentation to public procedures; add `<param>` and `<returns>` tags when they clarify the public contract.
- Comment the reason behind non-obvious business rules, validation, event/integration behavior, security assumptions, or transaction boundaries.
- Comments must be concise, accurate, and in English. Explain intent or constraints; do not narrate obvious statements or repeat the code.
- Do not comment every line. Avoid redundant comments, stale TODOs, and copied template comments that no longer describe the generated implementation.

### 6. Error Handling & Telemetry
- User-facing errors via `Error()`/`ErrorInfo` with actionable text; no silent `exit(false)`. Telemetry via `Session.LogMessage` — never log secrets/PII.

### 7. Data & Permissions
- Every functional feature ships a `PermissionSet` (or extension). Respect `DataClassification` on all new fields (default `CustomerContent`).

### 8. Translations
- All UI text via `Caption`/`ToolTip`/`Label` — no hardcoded literals. Regenerate `Translations/{AppName}.g.xlf` when captions change.

### 9. Version & app.json
- `app.json` mutated **EXCLUSIVELY** by BC Build & Publish Assistant Phase 0. Version bump: patch (fixes) / minor (feature) / major (breaking).

### 10. Terminal
- Max **400 chars per command** (payload only). Prefer read-only verification (`Test-Path`/`Select-String`).

### 11. Timing
- Report long-running actions as `Started: HH:MM:SS | Finished: HH:MM:SS | Total: Xm Ys` (UTC+7).

### 12. Build / Fix budget
- Max **3 build attempts**, max **3 CodeCop/AppSourceCop/PerTenantExtensionCop fix attempts**. On exhaustion → STOP, surface error + error-library reference, ask the user.

### 13. Agent Name Resolution (UAT incident rule)
- `agentName` MUST be the EXACT display name from Agent Map (e.g. `BC Build & Publish Assistant`). NEVER use the alias, a shortened form, or a paraphrase. Wrong name → silent no-op routing.

### 14. Secrets & Security
- NEVER expose PATs/tenant/client secrets/connection strings/internal paths. Credentials via Isolated Storage / secure config — never hardcoded.

### 15. Read-Only vs Write (orchestrator)
- Orchestrator's only WRITE action for AL objects is `run_subagent`. Read-only tools always allowed.

### 16. Layouts
- New reports: prefer Word (.docx) / Excel layouts; RDLC only when required. Layout file beside the report .al.

### 17. Dependencies
- New dependency added to app.json ONLY by BC Build & Publish Assistant Phase 0, with correct id/publisher/version from `.alpackages`.

### 18. Testing
- Non-trivial logic ships with a test codeunit (`Subtype = Test`) in a separate test app/range where provided.

### 19. Autonomy Contract
- Sub-agents run end-to-end WITHOUT asking for confirmation between internal phases. They return the Handoff Contract; the orchestrator reports, it does NOT re-execute.
