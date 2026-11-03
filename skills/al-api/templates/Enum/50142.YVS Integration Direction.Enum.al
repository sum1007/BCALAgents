// TEMPLATE: Integration direction & status enums (Level 1 logging layer)
// Generate ONCE per app. Re-prefix {PREFIX} and re-ID from the ID Allocation Ledger (Enum sub-range).

enum 50142 "YVS Integration Direction"
{
    Extensible = true;
    Caption = 'YVS Integration Direction';

    value(0; "Inbound") { Caption = 'Inbound'; }
    value(1; "Outbound") { Caption = 'Outbound'; }
}
