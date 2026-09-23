# Integration Logging Architecture — reference

Detailed field tables, type mapping, and generation rules for the al-api logging layer.
This document follows the current files in `templates/`. Summary lives in `SKILL.md`.

---

## Level 1 — `{PREFIX} Integration History` (shared header, one row per API call)

| Field | Type | DataClassification | Purpose |
|---|---|---|---|
| Entry No. | Integer (AutoIncrement, PK) | SystemMetadata | Unique log id |
| API Key | **Integer** | SystemMetadata | **Object id** of the API object. `TableRelation = AllObjWithCaption."Object ID"` |
| API Name | Text[100] | SystemMetadata | Cached object caption |
| Direction | Enum `{PREFIX} Integration Direction` | SystemMetadata | Inbound / Outbound |
| Batch Key | **Guid** | SystemMetadata | Groups the whole run |
| Request JSON | Blob | CustomerContent | Full request payload (secrets masked) |
| Response JSON | Blob | CustomerContent | Full response payload |
| Batch Status | Enum `{PREFIX} Integration Status` | SystemMetadata | Pending / Success / Error |
| Batch Log | Text[2048] | SystemMetadata | Trimmed error or batch log text |
| Record Count | Integer | SystemMetadata | Detail rows written |
| Transaction Date Time | DateTime | SystemMetadata | Time the transaction was completed |

**Keys**
- `PK` → `"Entry No."` (clustered)
- `Batch` → `"Batch Key"`
- `ApiDate` → `"API Key", "Created At"` is declared by the current template, but
    `Created At` is not currently declared as a field. Add that field or remove the
    key before compiling the generated app.

---

## Level 2 — `{PREFIX} {ApiName} Log` (one table per API)

Naming: `{PREFIX} {ApiName} Log` — e.g. `VAS Misa Invoice Log`, `VAS Airwallex Payout Log`.

### Fixed fields (always present)
| No. | Field | Type | DataClassification |
|---|---|---|---|
| 1 | API Key | **Integer** | SystemMetadata |
| 2 | Batch Key | **Guid** | SystemMetadata |
| 3 | Integration Key | Guid | SystemMetadata |

### Payload fields
Start at **field 10**, step 1. One field per request-payload property, typed, all carrying the `{PREFIX}` affix.

### Result fields
Start at **field 90**.
| No. | Field | Type |
|---|---|---|
| 90 | Status | Enum `{PREFIX} Integration Status` |
| 91 | Error Message | Text[2048] |

**Keys**
- `PK` → `"API Key", "Batch Key", "Integration Key"` (clustered)
- `Batch` → `"Batch Key"`
- one business key over the main document field (e.g. `"VAS Invoice No."`)

---

## Field numbering rule (summary)

```
1  – 3    fixed log header  (API Key, Batch Key, Integration Key)
10 – 89   payload fields    (typed, {PREFIX}-affixed)
90 +      result fields     (Status, Error Message)
```

---

## JSON → AL type mapping

| JSON type | Example value | AL type |
|---|---|---|
| string (identifier/code) | `"INV-001"`, `"C0001"` | `Code[20]` |
| string (free text) | `"ABC Company Ltd."` | `Text[100]` / `Text[250]` |
| string (long) | description, note | `Text[2048]` |
| number (money/qty) | `1500000.00` | `Decimal` |
| number (integer) | `42` | `Integer` |
| date | `"2026-09-08"` | `Date` |
| date-time | `"2026-09-08T10:00:00Z"` | `DateTime` |
| boolean | `true` | `Boolean` |
| enum-like string | `"Draft" \| "Posted"` | `Enum` (extensible) or `Code[20]` |
| nested object | `{ "address": {...} }` | flatten to `parentChild` fields |
| array | `[ {...}, {...} ]` | separate child log table linked by API Key + Batch Key |

---

## Worked example

Request payload:
```json
{ "invoiceNo": "INV-001", "customerCode": "C0001", "customerName": "ABC Co.",
  "invoiceDate": "2026-09-08", "amount": 1500000.00, "currency": "VND", "isVat": true }
```

Generated detail table fields:
| No. | Field | Type |
|---|---|---|
| 1 | API Key | Integer |
| 2 | Batch Key | Guid |
| 3 | Integration Key | Guid |
| 10 | VAS Invoice No. | Code[20] |
| 11 | VAS Customer Code | Code[20] |
| 12 | VAS Customer Name | Text[100] |
| 13 | VAS Invoice Date | Date |
| 14 | VAS Amount | Decimal |
| 15 | VAS Currency | Code[10] |
| 16 | VAS Is Vat | Boolean |
| 90 | Status | Enum |
| 91 | Error Message | Text[2048] |

See `templates/ApiDetailLog.Table.al` for the generated AL. `Integration Key` is
generated with `CreateGuid()` for each detail record and is also serialized by the
outbound sample.

---

## Execution contract

```
BatchKey := LogMgt.StartLog(ApiKey, Direction);                    // header, Pending
    -> insert one typed detail row per record (API Key + Batch Key + Integration Key + payload fields)
    -> call the partner API / process the inbound payload
LogMgt.FinishLog(RequestJson, ResponseJson, Status, ErrorMsg, RecordCount);
```

Rules:
- On failure, **still** call `FinishLog` with `Status = Error` and update the detail rows' status.
- The current template does not persist HTTP status code, endpoint URL, or duration.
- `Record Count` = number of detail rows inserted for that Batch Key.

---

## Secret masking

Before persisting any JSON, replace the values of:
- `Authorization` (Bearer tokens)
- `client_secret`, `clientSecret`
- `api_key`, `apiKey`, `x-api-key`
- `password`, `refresh_token`

with `'***'`. The `MaskSecret()` procedure exists in
`templates/IntegrationLogMgt.Codeunit.al`, but the current template still contains
a TODO and returns the payload unchanged. Implement the replacements before using
the template in production.
Never store raw credentials; never log PII into telemetry.

---

## Registering a new detail page

After generating a detail table + list page, add a branch to `OpenDetailPage()` in the header list page:

```al
Database::"VAS Misa Invoice Log":
    begin
        MisaLog.SetRange("API Key", Rec."API Key");
        MisaLog.SetRange("Batch Key", Rec."Batch Key");
        Page.Run(Page::"VAS Misa Invoice Log List", MisaLog);
    end;
```

---

## Retention (optional)

Log tables grow fast. If the project requires housekeeping, add a Job Queue codeunit that deletes
`{PREFIX} Integration History` entries older than N days together with their detail rows
(match on `Batch Key`). Keep error entries longer than success entries.

## Current template alignment notes

The templates are not fully aligned with one another yet:

- `IntegrationHistoryList.Page.al` reads `Status` and `Detail Table No.`, while
  `IntegrationHistory.Table.al` currently defines `Batch Status` and no `Detail Table No.`.
- `IntegrationHistory.Table.al` declares an `ApiDate` key using `Created At`, but
  no `Created At` field exists.
- `IntegrationLogMgt.Codeunit.al` defines `FinishLog` with five parameters. Some
  error branches in `OutboundSync.Codeunit.al` pass six parameters by including an
  HTTP status code.
- `StartLog` currently accepts only `ApiKey` and `Direction`; detail table number,
    endpoint URL, HTTP status code, and duration are not part of the current logging
    contract.

Resolve these template mismatches before generating a compilable app. Until then,
the tables and codeunit above are the source of truth for the current field and
procedure names.
