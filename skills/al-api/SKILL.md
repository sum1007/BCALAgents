---
name: al-api
description: Builds Business Central API pages, API queries, and inbound/outbound integrations in AL. Every integration requires a per-API engine and shared processing reports and logs. Outbound integrations also require the template-based external app setup, sync codeunit, API caller service, and API caller engine.
license: Proprietary
metadata:
  author: Votiva
  version: "1.4.0"
---

## SKILL: al-api — API Page / API Query, Integration & Per-API Logging (Dynamics 365 BC, AL)

> Owned by **BC Integration Generation Assistant** (@bc-integration-resource).
> Resolve `{PREFIX}` and object IDs from app-analysis §Quick Reference. NEVER guess. Template files use the sample prefix `YVS` and fixed IDs: treat them as examples, never copy them into a project. NEVER hardcode secrets.

## ⛔ MANDATORY OUTPUT — read first, applies whoever runs this skill

This applies whether the work is done by the integration agent or directly in the main chat. A request
that only names the API (for example **"create api upsert customer"** or **"create api upsert vendor"**)
is still a full integration. Before finishing, the destination app MUST contain each object below,
either reused (existing and compatible) or newly created as an `.al` file:

| # | Object | Scope | Template |
|---|---|---|---|
| 1 | API Key, Integration Direction, Integration Status enums (add this API's key value) | shared | `templates/Enum/50142…50144` |
| 2 | Integration History table | shared | `templates/Table/50103.YVS Integration History.Table.al` |
| 3 | Integration Engine codeunit | shared | `templates/CodeUnit/50129.YVS Integration Engine.Codeunit.al` |
| 4 | Integration History List page with **View Detail, Generate Data, Cancel Data, Reset Data** actions | shared | `templates/Page/50120.YVS Integration History List.Page.al` |
| 5 | **Generate Data** report (`ProcessingOnly = true`) | shared, one per app | `templates/Report/50101.YVS Generate Data.Report.al` |
| 6 | **Cancel Data** report (`ProcessingOnly = true`) | shared, one per app | `templates/Report/50102.YVS Cancel Data.Report.al` |
| 7 | **Reset Data** report (`ProcessingOnly = true`) | shared, one per app | `templates/Report/50103.YVS Reset Data.Report.al` |
| 8 | `{PREFIX} {ApiName} Log` detail table | per API | `templates/Table/50106…` (inbound) / `50107…` (outbound) |
| 9 | `{PREFIX} {ApiName} Log List` page | per API | `templates/Page/50122…` / `50124…` |
| 10 | API endpoint/handler codeunit (inbound) or sync codeunit (outbound) | per API | `templates/CodeUnit/50135…` / `50131…` |
| 11 | `{PREFIX} {ApiName} Engine` codeunit with `GenerateData`, `CancelData`, `ResetData` | per API | `templates/CodeUnit/50134.YVS Upsert Customer Engine.Codeunit.al` |
| 12 | PermissionSet covering all of the above, including the three reports | shared | `templates/50148.YVS-INTEGRATION.PermissionSet.al` |

Wiring that MUST exist: each of reports 5–7 has a `case "API Key"` branch for this API calling engine 11;
page 4's three actions run reports 5–7 via `ParmRecordId(Rec.SystemId)`; page 4's `OpenDetailPage()` routes
this API key to page 9.

These reports are integration objects created by this skill, not layout reports: do not route them to the
report pipeline. **Never** satisfy the build by deleting or commenting out the report actions, report
references, or dispatch branches. If the compiler says a report or engine does not exist, **create it**.
Do not report the task as complete while any row is missing; list each created/reused object (rows 1–12)
in the final answer or handoff.

### Additional mandatory output for outbound integrations

For **every outbound API**, also inventory the following; create missing `.al` files or reuse and extend
compatible existing objects. A permission reference alone is not an implementation. The sample names
describe roles, not names or IDs to copy into the destination app.

| Scope | Required object and role | Template |
|---|---|---|
| Per API | Typed sync detail log, one row per business record | `templates/Table/50107.YVS Sync Sales Invoice Log.Table.al` |
| Per API | Sync API codeunit: select data, write detail/history, build payload and invoke caller | `templates/CodeUnit/50131.YVS Sync Sales Invoice API.Codeunit.al` |
| Shared | External App Definition table keyed by API Key, with endpoint, method, authentication configuration, active flag and timeout | `templates/Table/50108.YVS External App Definition.Table.al` |
| Shared | External App Definition List and Card pages to maintain setup safely | `templates/Page/50123.YVS Ext. App Definition List.Page.al`, `templates/Page/50125.YVS Ext. App Definition Card.Page.al` |
| Shared | API Caller Service: resolve and validate setup for API Key; choose configured authentication; call the engine | `templates/CodeUnit/50132.YVS API Caller Service.Codeunit.al` |
| Shared | API Caller Engine: obtain access token when needed and send HTTP request using setup | `templates/CodeUnit/50133.YVS API Caller Engine.Codeunit.al` |
| Shared | OAuth enum and actual HTTP method type used by setup and engine | `templates/Enum/50146.YVS OAuth Type.Enum.al`; check the actual `Http Request Type` type before using `templates/Enum/50145.YVS HTTP Method.Enum.al` |

Preserve this template layering and call flow: report -> per-API processing engine -> per-API sync API
-> shared API Caller Service -> shared API Caller Engine -> third party. The service reads the shared
setup by the API key; the sync codeunit logs batch and detail outcomes. Adapt method signatures where
necessary so an existing selected batch is processed once, without creating a duplicate batch or
re-sending successful records. Never bypass these components with a hard-coded URL or a direct HTTP
call from the sync codeunit. Follow `references/logging-architecture.md` for required template fixes.

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
| Shared processing-only reports | `templates/Report/50101.YVS Generate Data.Report.al`, `50102.YVS Cancel Data.Report.al`, `50103.YVS Reset Data.Report.al` |
| Inbound payload handler | `templates/CodeUnit/50135.YVS Upsert Customer API.Codeunit.al` |
| Inbound record processor | `templates/CodeUnit/50134.YVS Upsert Customer Engine.Codeunit.al` |
| Inbound typed detail table and list | `templates/Table/50106.YVS Upsert Customer Log.Table.al`, `templates/Page/50122.YVS Upsert Customer Log List.Page.al` |
| Outbound sync and typed detail table | `templates/CodeUnit/50131.YVS Sync Sales Invoice API.Codeunit.al`, `templates/Table/50107.YVS Sync Sales Invoice Log.Table.al` |
| Outbound detail list | `templates/Page/50124.YVS Sales Invoice Log List.Page.al` |
| Outbound setup table and pages | `templates/Table/50108.YVS External App Definition.Table.al`, `templates/Page/50123.YVS Ext. App Definition List.Page.al`, `templates/Page/50125.YVS Ext. App Definition Card.Page.al` |
| HTTP/OAuth caller | `templates/CodeUnit/50132.YVS API Caller Service.Codeunit.al`, `50133.YVS API Caller Engine.Codeunit.al` |
| Permission sets for integration objects | `templates/50148.YVS-INTEGRATION.PermissionSet.al` |

These are project-specific AL examples with `YVS` names, concrete IDs, and sample business contracts. Use the template objects and their responsibilities as the starting point; allocate IDs from the current project's ledger, apply its prefix, replace sample payload/business fields, and update all references. Keep their architecture and existing compatible behavior; change only what the actual contract, secure credential storage, correctness, compilation, and required report integration demand. Do not copy known template defects or omit the required outbound components.

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

- Check whether the Level 1 shared history table, enums, engine, list page, three processing-only reports, and permissions already exist before generating them. Reuse shared objects and create only missing ones. Generate a Level 2 detail table and list for **every new integration contract**.
- Every integration also requires an **API-specific processing engine codeunit**. Find and extend an existing compatible engine, or create a new `.al` codeunit using the processor pattern for report dispatch, adapted to the integration's direction. The shared Integration Engine, outbound sync codeunit, and API endpoint/handler do not replace this engine. For customer upsert on a fresh app, use `templates/CodeUnit/50134.YVS Upsert Customer Engine.Codeunit.al` as the starting pattern.
- Every inbound **and** outbound integration must use the same three shared reports: Generate Data, Cancel Data, and Reset Data, one of each per app. Create them even when the request only says to create an API. Never create a separate set per API or per direction.
- Add an explicit API-key dispatch branch in **each** report to the appropriate per-API processing codeunit. Implement Generate, Cancel, and Reset for that API and direction using its real contract and business rules; reuse existing compatible codeunits. Generate processes eligible data, Cancel cancels eligible data, and Reset returns eligible data to a retryable state. Do not assume outbound processing is a Customer upsert or invent a partner cancellation operation. If an operation's business semantics are unclear, ask before implementing it.
- For the inbound upsert pattern, the handler validates and records the request and detail rows; the API-specific engine performs the business upsert from eligible rows through Generate. If the contract also requires immediate processing, invoke the same engine rather than duplicating upsert logic or processing the same rows twice.
- Wire all three history-list actions to the shared reports for the selected history record; preserve any existing equivalent actions. Report filters and per-API processing must restrict work to the selected API key and batch, and standalone execution must respect the user's filters.
- Update batch and detail statuses according to actual outcomes, including partial failures; do not mark a whole batch successful merely because one record succeeded. Operate only on eligible statuses, and do not silently overwrite successful rows or repeat external side effects. Preserve actionable failure details.
- Detail table fields derive from the **actual request payload contract** — same names, correct AL types, `{PREFIX}` affix on all.
- Follow the current template API (`CreateIntegrationHistory` / `UpdateIntegrationHistory`) only after checking its signature and key order. The templates do not define `StartLog` or `FinishLog`.
- Persist the history and detail rows on both success and failure; record per-record and batch failures using the project's status enum.
- Mask `Authorization`, `client_secret`, `api_key`, passwords, and tokens before storing JSON. The sample `MaskSecret` currently returns the input unchanged; implement and verify masking before using it.
- Never persist raw credentials. Use the project's secure secret-storage pattern (such as Isolated Storage) for credentials.
- For outbound, the external setup stores non-secret configuration and secure references; retrieve secrets from secure storage. Do not copy the template's masked Text secret/token/password fields as storage. Implement the configured auth mode from the real partner contract, and explicitly reject unsupported modes or missing/inactive setup.
- `DataClassification`: `SystemMetadata` for technical fields, `CustomerContent` for payload data.
- Generate a **List page for the header and every detail table**. Add a branch for each API key in the history page's `OpenDetailPage()` and filter the detail page by API Key + Batch Key.
- Ship/extend a PermissionSet covering the API, all log objects, all three shared reports, and their processing codeunits.

## Required processing objects — creation gate

Before creating an integration, inventory the destination app against **each** row. An existing equivalent
must actually implement the required role; a permission entry, template file, API handler, or planned
object does not count as an implementation. On a fresh app create all four `.al` files; otherwise reuse
and extend existing compatible objects and create each missing one. Allocate IDs and apply the app prefix.

| Required object | Source pattern | Required implementation |
|---|---|---|
| Per-API processing engine codeunit | `templates/CodeUnit/50134.YVS Upsert Customer Engine.Codeunit.al` | API-specific Generate, Cancel, and Reset operations scoped to API Key and Batch Key |
| Shared Generate Data report | `templates/Report/50101.YVS Generate Data.Report.al` | `ProcessingOnly`; dispatch this API key to its engine's Generate operation |
| Shared Cancel Data report | `templates/Report/50102.YVS Cancel Data.Report.al` | `ProcessingOnly`; dispatch this API key to its engine's Cancel operation |
| Shared Reset Data report | `templates/Report/50103.YVS Reset Data.Report.al` | `ProcessingOnly`; dispatch this API key to its engine's Reset operation |

These are required for requests such as **"create API upsert customer"**, not only when the user explicitly
asks for reports or an engine. The report patterns currently contain Customer-specific routing and known
status limitations; adapt and correct them as described in `references/logging-architecture.md`.
When business rules are missing, ask for the rules rather than claiming completion or inventing side effects.

## Steps

1. Resolve `{PREFIX}` and next free IDs for all required object types.
2. Inventory the Level 1 layer and all four processing objects against the creation gate; create missing `.al` files and reuse compatible existing objects.
3. Read the actual request/response contract and generate a per-API detail table with typed payload fields. For outbound, read and inventory every object in the outbound table above; create missing shared setup, setup pages, caller service and caller engine, plus the per-API sync codeunit.
4. Generate its detail List page; register the API key in the shared history page's routing case.
5. Implement inbound or outbound execution using the existing history engine's actual methods; persist batch and detail results for success and failure.
6. Implement all three operations in the per-API engine; add this API's dispatch to Generate, Cancel, and Reset and wire the history-list actions to the shared reports.
7. Add all API, logging, processing codeunit, and shared report objects to the permission set.
8. Update the ID Ledger and emit the Handoff Contract.

## Verify before handoff

- One shared Level 1 history layer exists; this integration has its own typed Level 2 detail table.
- The API key type and primary-key order match consistently across tables, engine methods, callers, and pages.
- Batch Key is the same GUID on the history row and every detail row; detail fields reflect the real payload contract.
- Header and per-API list pages exist; every routing branch filters by the correct API key and batch key.
- Exactly one shared Generate, Cancel, and Reset report exists per app, reused for both directions; all three dispatch the new API key to the appropriate per-API logic.
- Inspect the actual per-API engine and each report file, not just PermissionSet references or the handoff list. If any required file or route is missing, fix it before handoff; if blocked, identify the missing object and blocker instead of reporting success. Include changed files and paths of reused processing objects in the handoff.
- History actions invoke the correct report for the selected record. Verify batch isolation, eligible status transitions, partial failures, retries, and outbound side effects against the actual contract.
- For outbound, verify the actual files and call chain from the processing engine through the per-API sync codeunit, shared caller service, setup lookup and caller engine. Verify secure setup, permissions, configured authentication, transport and HTTP failures, empty successful responses, and persisted batch/detail results. List created and reused outbound objects in the handoff; report blockers rather than claiming completion.
- JSON is stored on the header only after secrets are masked. PermissionSet covers the API and all log objects.
- IDs are in range, project prefix is used, and no sample names, payloads, or `YVS` identifiers remain.
