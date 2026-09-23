// TEMPLATE: Integration direction & status enums (Level 1 logging layer)
// Generate ONCE per app. Re-prefix {PREFIX} and re-ID from the ID Allocation Ledger (Enum sub-range).

enum 50142 "VAS Integration Direction"
{
    Extensible = true;
    Caption = 'VAS Integration Direction';

    value(0; "Inbound") { Caption = 'Inbound'; }
    value(1; "Outbound") { Caption = 'Outbound'; }
}

enum 50143 "VAS Integration Status"
{
    Extensible = true;
    Caption = 'VAS Integration Status';

    value(0; "Pending") { Caption = 'Pending'; }
    value(1; "Success") { Caption = 'Success'; }
    value(2; "Error") { Caption = 'Error'; }
}
