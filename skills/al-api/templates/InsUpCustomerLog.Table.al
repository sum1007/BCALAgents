// TEMPLATE: Per-API detail log for the InsUpCustomer inbound contract.
// Generate one table per API. Re-prefix {PREFIX} and re-ID from the project ledger.
// The codeunit writes one typed row for each item in the request data array.

table 50106 "VAS InsUpCustomer Log"
{
    Caption = 'VAS InsUpCustomer Log';
    DataClassification = CustomerContent;

    fields
    {
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
            Caption = 'Integration Key';
            DataClassification = SystemMetadata;
        }
        field(10; "VAS Request Batch Key"; Guid)
        {
            Caption = 'Request Batch Key';
            DataClassification = SystemMetadata;
        }
        field(11; "VAS Line Number"; Integer)
        {
            Caption = 'Line Number';
            DataClassification = SystemMetadata;
        }
        field(12; "VAS Customer Id"; Code[20])
        {
            Caption = 'Customer Id';
            DataClassification = CustomerContent;
        }
        field(13; "VAS Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(14; "VAS Legal Entity Id"; Code[20])
        {
            Caption = 'Legal Entity Id';
            DataClassification = CustomerContent;
        }
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
        key(RequestLine; "VAS Request Batch Key", "VAS Line Number") { }
    }
}
