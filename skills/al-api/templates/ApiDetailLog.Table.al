// TEMPLATE: Level 2 per-API detail table — one row per record sent/received.
// Generate ONE PER API. Name it "{PREFIX} {ApiName} Log".
//
// Field numbering rule:
//   1 - 3    fixed log header (API Key, Batch Key, Line No.)
//   10 - 89  payload fields   (typed, {PREFIX}-affixed, one per request-payload property)
//   90 +     result fields    (Status, Error Message)
//
// The payload fields below are a SAMPLE for this contract:
//   { "invoiceNo": "INV-001", "customerCode": "C0001", "customerName": "ABC Co.",
//     "invoiceDate": "2026-09-08", "amount": 1500000.00, "currency": "VND", "isVat": true }
// Replace them with the real contract; see references/logging-architecture.md for type mapping.

table 50105 "VAS Misa Invoice Log"
{
    Caption = 'VAS Misa Invoice Log';
    DataClassification = CustomerContent;

    fields
    {
        // ---------- fixed log header fields ----------
        field(1; "API Key"; Integer)
        {
            Caption = 'API Key';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID";
        }
        field(2; "Batch Key"; Guid)
        {
            Caption = 'Batch Key';
            DataClassification = SystemMetadata;
        }
        field(3; "Integration Key"; Guid)
        {
            Caption = 'Integration Key.';
            DataClassification = SystemMetadata;
        }

        // ---------- payload fields (mirror the request contract) ----------
        field(10; "VAS Invoice No."; Code[20])
        {
            Caption = 'Invoice No.';
            DataClassification = CustomerContent;
        }
        field(11; "VAS Customer Code"; Code[20])
        {
            Caption = 'Customer Code';
            DataClassification = CustomerContent;
        }
        field(12; "VAS Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(13; "VAS Invoice Date"; Date)
        {
            Caption = 'Invoice Date';
            DataClassification = CustomerContent;
        }
        field(14; "VAS Amount"; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(15; "VAS Currency"; Code[10])
        {
            Caption = 'Currency';
            DataClassification = CustomerContent;
        }
        field(16; "VAS Is Vat"; Boolean)
        {
            Caption = 'Is VAT';
            DataClassification = CustomerContent;
        }

        // ---------- per-record result ----------
        field(90; "Integration Status"; Enum "VAS Integration Status")
        {
            Caption = 'Integration Status';
            DataClassification = SystemMetadata;
        }
        field(91; "Integration Log"; Text[2048])
        {
            Caption = 'Integration Log';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "API Key", "Batch Key", "Integration Key") { Clustered = true; }
        key(Batch; "API Key", "Batch Key") { }
        key(Doc; "VAS Invoice No.") { }
    }
}
