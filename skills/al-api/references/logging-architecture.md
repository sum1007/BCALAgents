# Integration Logging Architecture

This reference describes the current examples under `templates/`. Their `YVS` prefix, object IDs, and payloads are project-specific sample data. Reuse the applicable design only; resolve the destination app's prefix, object IDs, payload contract, and shared-object availability before generating AL.

## Level 1 — shared integration history

Current example: `templates/Table/50103.YVS Integration History.Table.al`.

| Field | Type | Classification | Purpose |
|---|---|---|---|
| API Key | Enum `YVS API Key` | SystemMetadata | Integration identifier; **not** an AL object ID |
| Direction | Enum `YVS Integration Direction` | SystemMetadata | Inbound or outbound |
| Batch Key | Guid | SystemMetadata | Groups the history and detail records for one batch |
| Request JSON | Blob | CustomerContent | Request payload after secret masking |
| Response JSON | Blob | CustomerContent | Response payload |
| Batch Status | Enum `YVS Integration Status` | SystemMetadata | Pending, Success, Failed, or Cancelled |
| Batch Log | Text[2048] | SystemMetadata | Batch-level message |
| Record Count | Integer | SystemMetadata | Number of detail records |
| Transaction Date Time | DateTime | SystemMetadata | Transaction time |
| Processing | Boolean | SystemMetadata | Processing flag used by the sample |

The table's primary key is `("Batch Key", "API Key")`. Its request/response Blob accessors are `SetRequestJson`, `GetRequestJson`, `SetResponseJson`, and `GetResponseJson`.

## Level 2 — per-integration detail log

Current examples:

- Inbound: `templates/Table/50106.YVS Upsert Customer Log.Table.al`
- Outbound: `templates/Table/50107.YVS Sync Sales Invoice Log.Table.al`

Both use these fixed fields:

| Field | Type | Classification |
|---|---|---|
| API Key | Enum `YVS API Key` | SystemMetadata |
| Batch Key | Guid | SystemMetadata |
| Integration Key | Guid | SystemMetadata |
| Integration Status | Enum `YVS Integration Status` | SystemMetadata |
| Integration Log | Text[2048] | SystemMetadata |

The primary key is `("API Key", "Batch Key", "Integration Key")`. The samples also show optional business/reference fields such as `Ref System Id` and `Line Number`; payload data is stored in typed columns with `CustomerContent` classification. Select field numbers from the app's field-ID allocation rules and avoid collisions. The examples do not implement a universal reserved field-number range.

`Integration Key` identifies a detail record. The inbound example accepts it from the request and creates a GUID if missing; the outbound example creates a GUID for each logged invoice. Decide whether the key is supplied or generated from the real integration contract.

## Enums and current status values

- `templates/Enum/50142.YVS Integration Direction.Enum.al`: `Inbound`, `Outbound`
- `templates/Enum/50143.YVS Integration Status.Enum.al`: `Pending`, `Success`, `Failed`, `Cancelled`
- `templates/Enum/50144.YVS API Key.Enum.al`: one value per configured integration

Do not assume the status enum contains `Error`, or that the API key is an object ID. If an app requires a different API-key representation, update all dependent table fields, method parameters, assignments, lookups, and page routing consistently.

## Current engine procedures

The shared codeunit is `templates/CodeUnit/50129.YVS Integration Engine.Codeunit.al`. Its main procedures are:

```al
CreateIntegrationHistory(
    ApiKey: Enum "YVS API Key";
    BatchKey: Guid;
    Direction: Enum "YVS Integration Direction";
    TransDateTime: DateTime;
    TotalRecords: Integer;
    JsonRequest: Text;
    JsonResponse: Text;
    BatchLog: Text)

UpdateIntegrationHistory(
    ApiKey: Enum "YVS API Key";
    BatchKey: Guid;
    TransactionDateTime: DateTime;
    RequestJson: Text;
    ResponseJson: Text;
    IntegrationStatus: Enum "YVS Integration Status";
    IntegrationLog: Text;
    RecordCount: Integer)
```

The outbound example creates a GUID, inserts typed detail rows, creates the history row, calls the partner API, and updates the history result. The inbound example parses the request, inserts detail rows, and updates the history record. The templates do not define `StartLog` or `FinishLog`; do not generate callers for those methods.

For both directions, persist batch and per-record outcomes on success and failure. Ensure request/response JSON is secret-masked before writing it to the history Blob fields.

## JSON-to-AL type guidance

Choose AL types using the actual schema, expected length, and BC semantics:

| JSON value | Common AL type |
|---|---|
| Identifier or code | `Code[n]` |
| Short or free-form text | `Text[n]` |
| Long text | `Text[2048]` or an appropriate large-text representation |
| Money or quantity | `Decimal` |
| Integer | `Integer` |
| Date | `Date` |
| Date/time | `DateTime` |
| Boolean | `Boolean` |
| Stable finite choice | Extensible `Enum` or `Code[n]`, per contract |
| Nested object | Flatten into clearly named typed fields or a related detail structure |
| Array of records | Per-record detail rows, or a child table if nested arrays require it |

Preserve the external contract's property meaning and validation; do not mechanically infer storage length from one example.

## Detail-page routing and permissions

The shared history page is `templates/Page/50120.YVS Integration History List.Page.al`. Its `OpenDetailPage()` uses a case on the API-key enum and filters the selected detail table by API Key and Batch Key before opening its list page. Add one route for every generated detail list, including any outbound detail list.

The detail-list examples include a navigation action back to the history list. Extend the permission set at `templates/50148.YVS-INTEGRATION.PermissionSet.al` to include every new API object, detail table, detail page, processing codeunit, and any required shared object. The sample permission set is not automatically complete for a different app or feature set.

## Secrets and JSON logging

The shared engine's `MaskSecret()` currently contains a TODO and returns the payload unchanged. This is **not safe to use as-is**. Implement and test masking for the actual partner schema (including authorization headers, client secrets, API keys, passwords, and access/refresh tokens) before persisting JSON. Never log raw credentials. Store credentials using the app's approved secure storage mechanism, such as Isolated Storage.

## Current template caveats — resolve before materializing

- The header and detail tables use `Enum "YVS API Key"`, but some page tooltips describe API Key as an object ID. The current schema does not store or validate an AL object ID.
- The history table primary key is ordered as `("Batch Key", "API Key")`, while `UpdateIntegrationHistory` calls `History.Get(ApiKey, BatchKey)`. `Record.Get` arguments follow primary-key order; reconcile this mismatch before relying on the update path.
- The inbound handler `50135.YVS Upsert Customer API.Codeunit.al` overwrites its `payload` parameter with a hard-coded sample JSON body. Remove that assignment before using the handler with real requests.
- `MaskSecret()` is a no-op until implemented, so the current history engine can persist unmasked credentials.
- The history list's detail-routing case currently handles Upsert Customer only, although an outbound sales-invoice detail page is also present. Add and verify all required routes.
- The examples do not persist duration or HTTP status code in the history schema. Add those fields and wire them through the engine if required.
- `CreateIntegrationHistory` and `UpdateIntegrationHistory` are distinct operations, not a transaction-safe Start/Finish abstraction. Check transaction boundaries and failure paths for the intended durability guarantees.
