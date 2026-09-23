// TEMPLATE: PermissionSet covering the API objects and the whole logging layer.
// Extend this set every time a new per-API detail table + list page is generated.
// Re-prefix {PREFIX} and re-ID from the Ledger (PermissionSet sub-range).

permissionset 50148 "VAS-INTEGRATION"
{
    Assignable = true;
    Caption = 'VAS Integration - Full';

    Permissions =
        // ---------- Level 1: shared header ----------
        tabledata "VAS Integration History" = RIMD,
        table "VAS Integration History" = X,
        page "VAS Integration History List" = X,
        codeunit "VAS Integration Log Mgt." = X,

        // ---------- Level 2: per-API detail tables (add one block per API) ----------
        tabledata "VAS Misa Invoice Log" = RIMD,
        table "VAS Misa Invoice Log" = X,
        page "VAS Misa Invoice Log List" = X,
        codeunit "VAS Misa Invoice Sync" = X,

        // ---------- API endpoints ----------
        page "VAS Api Customers" = X;
}

// Read-only variant for reviewers / support.
permissionset 50149 "VAS-INTEGRATION-READ"
{
    Assignable = true;
    Caption = 'VAS Integration - Read Only';

    Permissions =
        tabledata "VAS Integration History" = R,
        tabledata "VAS Misa Invoice Log" = R,
        page "VAS Integration History List" = X,
        page "VAS Misa Invoice Log List" = X;
}
