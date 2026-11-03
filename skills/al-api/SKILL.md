---
name: al-api
description: Builds Business Central API pages, API queries, and inbound/outbound integrations in AL. Integration examples use one shared history header keyed by an API enum and batch GUID, plus a per-API typed detail log and list pages. Use when exposing OData endpoints or calling partner APIs such as MISA, Airwallex, or Dynamicweb.
license: Proprietary
metadata:
  author: Votiva
  version: "1.3.0"
---

## SKILL: al-api — API Page / API Query, Integration & Per-API Logging (Dynamics 365 BC, AL)

> Owned by **BC Integration Generation Assistant** (@bc-integration-resource).
> Resolve `{PREFIX}` and object IDs from app-analysis §Quick Reference. NEVER guess. Template files use the sample prefix `YVS` and fixed IDs: treat them as examples, never copy them into a project. NEVER hardcode secrets.

### When to use

- Expose data via OData v4 → **API Page** (read/write) or **API Query** (read-only, aggregations).
- Outbound calls / scheduled sync → **Codeunit** (+ Job Queue). Auth secrets via **Isolated Storage**.
- Inbound request processing or outbound synchronization → **MUST write to the Integration Logging layer**.
- The current templates demonstrate codeunit-based inbound processing and outbound sync. They do **not** provide an API Page or API Query sample.

---

## Logging architecture (summary)

| Level | Object | Created | Holds |
|---|---|---|---|
| 1 | `{PREFIX} Integration History` | **once per app** | one row per batch: API key, batch key, request/response JSON, status, and counts |
| 2 | `{PREFIX} {ApiName} Log` | **one per API** | one typed row per payload record, plus per-record processing status |

**Key conventions (HARD)**

- In the current templates, **API Key is `Enum {PREFIX} API Key`**, with one enum value per integration. It is **not** an AL object ID; do not describe it as an object ID or substitute an integer without changing the table, callers, and routing code together.
- **Batch Key = `Guid`**, generated once for a run and shared by its header and detail rows.
- The current detail-table PK is `("API Key", "Batch Key", "Integration Key")`; `Integration Key` is a `Guid`. Do not replace it with a line number unless the chosen payload contract requires that change.
- Detail fields are **typed columns**, not a JSON blob. Request and response JSON are stored on the shared header.
- Current status values are `Pending`, `Success`, `Failed`, and `Cancelled`; use the project enum's actual values rather than assuming an `Error` value.

→ Current fields, signatures, type guidance, and template caveats: **`references/logging-architecture.md`**

---

## Templates (read the files; do not inline or copy their sample identity)

| Need | Current example |
|---|---|
| Direction, status, and API-key enums | `templates/Enum/50142.YVS Integration Direction.Enum.al`, `50143.YVS Integration Status.Enum.al`, `50144.YVS API Key.Enum.al` |
| HTTP method and OAuth enums | `templates/Enum/50145.YVS HTTP Method.Enum.al`, `50146.YVS OAuth Type.Enum.al` |
| Shared history header table | `templates/Table/50103.YVS Integration History.Table.al` |
| Shared integration/history engine | `templates/CodeUnit/50129.YVS Integration Engine.Codeunit.al` |
| History list and detail-page routing | `templates/Page/50120.YVS Integration History List.Page.al` |
| Inbound payload handler | `templates/CodeUnit/50135.YVS Upsert Customer API.Codeunit.al` |
| Inbound record processor | `templates/CodeUnit/50134.YVS Upsert Customer Engine.Codeunit.al` |
| Inbound typed detail table and list | `templates/Table/50106.YVS Upsert Customer Log.Table.al`, `templates/Page/50122.YVS Upsert Customer Log List.Page.al` |
| Outbound sync and typed detail table | `templates/CodeUnit/50131.YVS Sync Sales Invoice API.Codeunit.al`, `templates/Table/50107.YVS Sync Sales Invoice Log.Table.al` |
| Outbound detail list | `templates/Page/50124.YVS Sales Invoice Log List.Page.al` |
| HTTP/OAuth caller | `templates/CodeUnit/50132.YVS API Caller Service.Codeunit.al`, `50133.YVS API Caller Engine.Codeunit.al` |
| Permission sets for integration objects | `templates/50148.YVS-INTEGRATION.PermissionSet.al` |

These are project-specific AL examples with `YVS` names, concrete IDs, and sample business contracts. Copy their **applicable structure only**: allocate IDs from the current project's ledger, apply its prefix, replace sample payload/business fields, and update every reference in pages, codeunits, enums, and permission sets. The folder also contains non-API examples; use them only when the requested feature needs them.

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

- Check whether the Level 1 shared history table, enums, engine, list page, and permissions already exist before generating them. Generate a Level 2 detail table and list for **every new integration contract**.
- Detail table fields derive from the **actual request payload contract** — same names, correct AL types, `{PREFIX}` affix on all.
- Follow the current template API (`CreateIntegrationHistory` / `UpdateIntegrationHistory`) only after checking its signature and key order. The templates do not define `StartLog` or `FinishLog`.
- Persist the history and detail rows on both success and failure; record per-record and batch failures using the project's status enum.
- Mask `Authorization`, `client_secret`, `api_key`, passwords, and tokens before storing JSON. The sample `MaskSecret` currently returns the input unchanged; implement and verify masking before using it.
- Never persist raw credentials. Use the project's secure secret-storage pattern (such as Isolated Storage) for credentials.
- `DataClassification`: `SystemMetadata` for technical fields, `CustomerContent` for payload data.
- Generate a **List page for the header and every detail table**. Add a branch for each API key in the history page's `OpenDetailPage()` and filter the detail page by API Key + Batch Key.
- Ship/extend a PermissionSet covering the API + all log objects.

## Steps

1. Resolve `{PREFIX}` and next free IDs for all required object types.
2. Check for an existing Level 1 layer; add only missing shared objects.
3. Read the actual request/response contract and generate a per-API detail table with typed payload fields.
4. Generate its detail List page; register the API key in the shared history page's routing case.
5. Implement inbound or outbound execution using the existing history engine's actual methods; persist batch and detail results for success and failure.
6. Add all API and logging objects to the permission set.
7. Update the ID Ledger and emit the Handoff Contract.

## Verify before handoff

- One shared Level 1 history layer exists; this integration has its own typed Level 2 detail table.
- The API key type and primary-key order match consistently across tables, engine methods, callers, and pages.
- Batch Key is the same GUID on the history row and every detail row; detail fields reflect the real payload contract.
- Header and per-API list pages exist; every routing branch filters by the correct API key and batch key.
- JSON is stored on the header only after secrets are masked. PermissionSet covers the API and all log objects.
- IDs are in range, project prefix is used, and no sample names, payloads, or `YVS` identifiers remain.
