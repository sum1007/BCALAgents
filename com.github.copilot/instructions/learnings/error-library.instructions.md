## Error Library — Dynamics 365 Business Central (AL)

Fast-lookup table for build/compile/publish failures. BC Build & Publish Assistant consults this BEFORE burning a fix attempt.
Format: **Symptom → Root cause → Fix**. Append new learnings at the bottom.

### Compile — Object / Symbol resolution
| Code / Message | Root cause | Fix |
|---|---|---|
| **AL0185** "type or method X is not found" | Missing dependency / stale symbols | `AL: Download Symbols`; confirm dependency in app.json (added by Build & Publish Phase 0). |
| **AL0432** "marked for removal. ObsoleteState = Pending" | Using a base member being obsoleted | Switch to the replacement in the ObsoleteReason; do not suppress. |
| **AL0118** "name X does not exist in current context" | Typo / wrong scope / missing `var` | Verify via `find_symbol`; declare/qualify correctly. |
| "Symbols not loaded" / squiggles everywhere | `.alpackages` empty / wrong server version | `AL: Download Symbols`; check app.json application/platform. |

### AppSourceCop / CodeCop / PerTenantExtensionCop
| Rule | Message | Fix |
|---|---|---|
| **AS0011** | "object must have an affix" | Add `{PREFIX}` affix (from §Quick Reference). |
| **AS0009** | "object ID not within allowed range" | Reassign to a free ID inside `{ObjectIdRange}`; update Ledger. |
| **AS0072** | "Field must have valid DataClassification" | Set `DataClassification` (default `CustomerContent`). |
| **AS0018** | "Removing/altering a field/key is breaking" | Obsoletion cycle; never hard-delete shipped members. |
| **AA0008** | "Parentheses required for function call" | Add `()` to the call. |
| **AA0137** | "Variable declared but never used" | Remove the unused variable. |
| **AA0470** | "Placeholders in labels must be documented" | Add `Comment = '%1 = ...'`. |
| **PTE0001** | "object type not allowed for PTE" | Restructure or move to an AppSource app. |

### Missing UI text / Translations
| Symptom | Root cause | Fix |
|---|---|---|
| Control has no Caption | Hardcoded literal / missing Caption | Add `Caption`/`ToolTip`; regenerate `{AppName}.g.xlf`. |
| Translation file out of date | Captions changed without re-gen | Rebuild with `TranslationFile: true`/`GenerateCaptions`. |

### Publish / Runtime
| Symptom | Root cause | Fix |
|---|---|---|
| "schema breaking change" on deploy | Table change vs published without allowed sync | Data-preserving change; `ForceSync` only in DEV, never PROD. |
| "Dependency not installed" | Required app not published on tenant | Install dependency first; verify version in app.json. |
| Install/Upgrade codeunit not firing | Wrong `Subtype` / not registered | Ensure `Subtype = Install`/`Upgrade` and part of the compiled app. |
| Publish OK but object not visible | Missing PermissionSet assignment | Assign the feature PermissionSet to the user/role. |

### Escalation
After **3** fix attempts on the same rule/error → STOP. Surface: last error text, file/line, matched entry, tried fixes. Ask the user.

### Append new learnings below
<!-- YYYY-MM-DD | Symptom | Root cause | Fix | Related object -->
