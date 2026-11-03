// TEMPLATE: PermissionSet covering the API objects and the whole logging layer.
// Extend this set every time a new per-API detail table + list page is generated.
// Re-prefix {PREFIX} and re-ID from the Ledger (PermissionSet sub-range).

permissionset 50148 "YVS-INTEGRATION"
{
    Assignable = true;
    Caption = 'YVS Integration - Full';

    Permissions =
        // ---------- Level 1: shared header ----------
        tabledata "YVS Integration History" = RIMD,
        table "YVS Integration History" = X,
        page "YVS Integration History List" = X,
        codeunit "YVS Integration Engine" = X,

        // ---------- Level 2: per-API detail tables (add one block per API) ----------
        tabledata "YVS Sync Sales Invoice Log" = RIMD,
        table "YVS Sync Sales Invoice Log" = X,
        page "YVS Sales Invoice Log List" = X,
        tabledata "YVS External App Definition" = RIMD,
        table "YVS External App Definition" = X,
        page "YVS Ext. App Definition List" = X,
        tabledata "YVS Upsert Customer Log" = RIMD,
        table "YVS Upsert Customer Log" = X,
        page "YVS Upsert Customer Log List" = X,
        codeunit "YVS Upsert Customer Engine" = X,

        // ---------- API endpoints ----------
        codeunit "YVS Sync Sales Invoice API" = X,
        report "YVS Generate Data" = X;
}

// Read-only variant for reviewers / support.
permissionset 50149 "YVS-INTEGRATION-READ"
{
    Assignable = true;
    Caption = 'YVS Integration - Read Only';

    Permissions =
        tabledata "YVS Integration History" = R,
        tabledata "YVS Sync Sales Invoice Log" = R,
        page "YVS Integration History List" = X,
        page "YVS Sales Invoice Log List" = X;
}
