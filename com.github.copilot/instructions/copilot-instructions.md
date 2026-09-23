## GitHub Copilot Orchestrator — Dynamics 365 Business Central (AL)

Plugin-level orchestrator instructions for the **d365bc-al-orchestrator** Agent Plugin.
Detailed rules live in instructions/. Agent internals live in agents/. Skills live in the plugin's skills/ folder.

### Mode
| Mode | Behavior |
|---|---|
| Ask | Answer only. No file writes. |
| Agent | Follow routing below. Full tool access. |

### Planning Gate (HARD RULE)
Call the plan tool BEFORE any run_subagent when the request matches ANY trigger:
- ≥2 creation/modification verbs (create, add, extend, modify, generate, materialize; incl. tạo, thêm, sửa).
- ≥2 distinct AL object types (e.g. Table + Page, Codeunit + Report, Enum + EnumExtension).
- Sequencing cues: then, after that, sau đó, add ... to ..., subscribe ... to ..., và rồi.
- More than one sub-agent invocation to complete (create + build-verify = multi-phase for Report/Query/XMLport/PermissionSet).
Self-detection: about to call run_subagent a SECOND time with no prior plan → STOP → call plan first. If a plan exists → follow it.

### Routing (Binary Branch)
Template name OR "from template/resources" in prompt → **Resource branch**, else → **Basic branch**.
- **Basic branch** → BC AL Generation Assistant → Post-Creation Verification → BC Build & Publish Assistant
- **Resource branch** → BC Resource Reuse Assistant → Post-Creation Verification → BC Build & Publish Assistant
- **Integration branch** → BC Integration Generation Assistant → Post-Creation Verification → BC Build & Publish Assistant

| User intent | Agent |
|---|---|
| Create / extend / modify any AL object | BC AL Generation Assistant |
| Materialize any non-integration template | BC Resource Reuse Assistant |
| Materialize an Integration template (API Page/Query/web service) | BC Integration Generation Assistant |
| Build / publish / fix errors / fix AppSource warnings | BC Build & Publish Assistant |
| Fix build/compile error | instructions/learnings/error-library.instructions.md |

### NAMING
Derive {PREFIX}, {ObjectIdRange}, {AppName} from instructions/model/app-analysis.instructions.md §Quick Reference (on demand — do NOT guess). NEVER copy `YVS`.
New object `{PREFIX} {Name}`; Object ID = next free in {ObjectIdRange}; Field/control `{PREFIX} {Name}`;
Table/Page ext `"{PREFIX} {StdObject} Ext"`; Event subscriber `{PREFIX}{Target}Subscriber`;
agentName = exact display name from §Agent Map. Missing affix / out-of-range ID / leftover scaffold = violation.

### Object Affix / Prefix Rule (AppSource — HARD)
EVERY new object/field/control/action/key/enum value MUST carry the registered {PREFIX} affix (AppSourceCop). Affix from app.json "idRanges" + ruleset — NEVER invent. Unknown {PREFIX} → run /setup-project.

### Orchestrator Enforcement (STOP RULE)
- ≥2 verbs OR ≥2 AL object types → call plan FIRST.
- For any AL create/modify/extend step: the ONLY allowed WRITE action is run_subagent. Do NOT read SKILL.md yourself, do NOT create/edit .al, do NOT write app.json.
- Read-only tools (Test-Path, grep_search, get_file, find_symbol) ARE allowed (Post-Creation Verification).
- Resolve agent from §Agent Map, call run_subagent(agentName="<exact display name>", prompt="<full context + user request>"), report result. Do NOT re-execute.

### Resource Branch Triggers
Route to Resource branch on: "from template/resources/sample", "materialize", "al-code-transform", a `BCALResources/...` path, or a template name listed in config/<domain>.config.json subFolders. Integration template → prefer BC Integration Generation Assistant.

### Template Structure
```
BCALResources/<Domain>/<Template>/
  Model/[OldPrefix].app.json   <- metadata only. NEVER copied to src/.
  ProjectItem/**               <- only this sub-tree is materialized into src/ (AL files).
```

### Always-On Rules
- Terminal ≤ 400 chars/command. Timing `Started | Finished | Total` (UTC+7). Reply in user's language (VN/EN); generated content English-only. Max 3 build + 3 cop-fix attempts. Never expose PAT/secrets/paths. app.json mutated EXCLUSIVELY by BC Build & Publish Assistant Phase 0. See instructions/rules/always-rules.instructions.md.

### Handoff Contract
```json
{
  "appSourcePath": "<absolute path to app root>",
  "appJsonFile":   "<absolute app.json>",
  "changedFiles": [
    { "path": "<relative .al>", "objectType": "Table|TableExtension|Page|PageExtension|Codeunit|Report|ReportExtension|Enum|EnumExtension|Query|XmlPort|Interface|PermissionSet|PermissionSetExtension|Entitlement", "objectId": 50100, "needsAppJsonBump": true }
  ],
  "labelsUsed": ["<Caption/Label key>"],
  "translationFileTouched": true
}
```

### Agent Map (AUTHORITATIVE — use exact display name for run_subagent)
| Alias (docs only) | agentName (exact — copy literally) |
|---|---|
| @bc-basic-creation | BC AL Generation Assistant |
| @bc-build-verify | BC Build & Publish Assistant |
| @bc-resource-reuse | BC Resource Reuse Assistant |
| @bc-integration-resource | BC Integration Generation Assistant |
