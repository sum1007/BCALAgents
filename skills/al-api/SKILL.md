---
name: al-api
description: Builds Business Central API pages, API queries, and inbound/outbound integrations in AL, and always generates the integration logging layer — one shared Integration History header keyed by API object id and a GUID batch key, plus a dedicated per-API detail table whose fields mirror the request payload, with list pages for each. Use when exposing OData endpoints, calling partner APIs such as MISA, Airwallex, or Dynamicweb, or when audit, tracing, and replay of integration payloads is required.
license: Proprietary
metadata:
  author: Votiva
  version: "1.3.0"
---

## SKILL: al-api — API Page / API Query, Integration & Per-API Logging (Dynamics 365 BC, AL)

> Owned by **BC Integration Generation Assistant** (@bc-integration-resource).
> Resolve `{PREFIX}`, `{ObjectIdRange}` from app-analysis §Quick Reference. NEVER guess. NEVER copy `YVS`. NEVER hardcode secrets.

### When to use
- Expose data via OData v4 → **API Page** (read/write) or **API Query** (read-only, aggregations).
- Outbound calls / scheduled sync → **Codeunit** (+ Job Queue). Auth secrets via **Isolated Storage**.
- **ANY inbound or outbound execution → MUST write to the Integration Logging layer.**

---

## Logging architecture (summary)

| Level | Object | Created | Holds |
|---|---|---|---|
| 1 | `{PREFIX} Integration History` | **once per app** (idempotent) | one row per call: API Key, Batch Key, request/response JSON, status, timing |
| 2 | `{PREFIX} {ApiName} Log` | **one per API** | one row per record, **typed columns mirroring the request payload** |

**Key conventions (HARD)**
- **API Key = `Integer` = the AL object id** of the API object. Set via `Page::"..."` / `Codeunit::"..."`. `TableRelation = AllObjWithCaption."Object ID"`.
- **Batch Key = `Guid`** from `CreateGuid()`, shared by the header row and every detail row of that run.
- Detail PK = `("API Key", "Batch Key", "Line No.")`.
- Detail fields are **typed columns**, not a JSON blob. Raw JSON stays on the header.

→ Full field tables, type mapping, and field-numbering rules: **`references/logging-architecture.md`**

---

## Templates (read the file, do not inline it here)

| Need | Template file |
|---|---|
| Direction / Status enums | `templates/IntegrationEnums.al` |
| Level 1 shared header table | `templates/IntegrationHistory.Table.al` |
| Level 2 per-API detail table | `templates/ApiDetailLog.Table.al` |
| Logging codeunit (Start/Finish) | `templates/IntegrationLogMgt.Codeunit.al` |
| Outbound sync usage pattern | `templates/OutboundSync.Codeunit.al` |
| Inbound API page + logging | `templates/InboundApiPage.Page.al` |
| Inbound InsUpCustomer codeunit | `templates/InsUpCustomer.Codeunit.al` |
| InsUpCustomer detail log | `templates/InsUpCustomerLog.Table.al` |
| InsUpCustomer detail list | `templates/InsUpCustomerLogList.Page.al` |
| Header list page (drill-down) | `templates/IntegrationHistoryList.Page.al` |
| Per-API detail list page | `templates/ApiDetailLogList.Page.al` |
| PermissionSet for log objects | `templates/IntegrationPermissionSet.al` |

Copy the template, then re-prefix, re-ID, and replace the sample payload fields with the real contract.

---

## API metadata contract (HARD — keep stable, must not collide)
| Property | Rule |
|---|---|
| `APIPublisher` | project-owned, stable (e.g. 'votiva') |
| `APIGroup` | logical group (e.g. 'vas') |
| `APIVersion` | 'v1.0' (bump only on breaking API change) |
| `EntityName` / `EntitySetName` | singular / plural, prefixed |
| `ODataKeyFields` | stable key (usually SystemId) |
| `PageType` / `QueryType` | `API` |
| `DelayedInsert` | `true` on API pages with required fields |

---

## Rules (HARD)
- Level 1 generated ONCE (check existence first). Level 2 generated **for every new API**.
- Detail table fields derive from the **actual request payload contract** — same names, correct AL types, `{PREFIX}` affix on all.
- Every execution: `StartLog` (Pending) → insert typed detail rows → `FinishLog` (JSON + status + duration). **On error still persist** header + details with Status=Error.
- Mask `Authorization` / `client_secret` / `api_key` before storing JSON. Never persist raw credentials.
- `DataClassification`: `SystemMetadata` for technical fields, `CustomerContent` for payload data.
- Generate a **List page for the header and for every detail table**; header drills down filtered by API Key + Batch Key.
- Ship/extend a PermissionSet covering the API + all log objects.

## Steps
1. Resolve `{PREFIX}` + next free IDs (Enums, Tables, Codeunit, Pages).
2. If Level 1 missing → generate from templates: enums, header table, log codeunit, header list page, PermissionSet.
3. **For this API**: read the request payload contract → generate `{PREFIX} {ApiName} Log` from `ApiDetailLog.Table.al` with typed fields.
4. Generate its detail List page; register a `case` branch in the header page's `OpenDetailPage()`.
5. Build the API object; wrap execution with `{PREFIX} Integration Log Mgt.`
6. Update ID Ledger; emit Handoff Contract.

## Verify before handoff
- Level 1 exists once; a dedicated `{PREFIX} {ApiName} Log` table generated for THIS API.
- `API Key` is an Integer object id; `Batch Key` is a Guid shared header ↔ all detail rows.
- Detail fields mirror the payload with correct types + affix; PK = (API Key, Batch Key, Line No.).
- List page exists for header AND each detail table; drill-down filters correctly.
- JSON stored on header with secrets masked. PermissionSet covers API + log objects.
- IDs in range, no scaffold names, no `YVS`.
