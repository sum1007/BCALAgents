// TEMPLATE: Level 1 shared header table — one row per API call.
// Generate ONCE per app (idempotent). Re-prefix {PREFIX} and re-ID from the Ledger (Table sub-range).
// API Key  = Integer object id of the API object (Page::"..." / Codeunit::"...").
// Batch Key = Guid from CreateGuid(), shared with every detail row of the run.

table 50103 "YVS Integration History"
{
    Caption = 'YVS Integration History';
    DataClassification = SystemMetadata;
    LookupPageId = "YVS Integration History List";
    DrillDownPageId = "YVS Integration History List";

    fields
    {
        field(1; "API Key"; Enum "YVS API Key")
        {
            Caption = 'API Key';
            DataClassification = SystemMetadata;
        }
        field(3; Direction; Enum "YVS Integration Direction")
        {
            Caption = 'Direction';
            DataClassification = SystemMetadata;
        }
        field(4; "Batch Key"; Guid)
        {
            Caption = 'Batch Key';
            DataClassification = SystemMetadata;
        }
        field(5; "Request JSON"; Blob)
        {
            Caption = 'Request JSON';
            DataClassification = CustomerContent;
        }
        field(6; "Response JSON"; Blob)
        {
            Caption = 'Response JSON';
            DataClassification = CustomerContent;
        }
        field(7; "Batch Status"; Enum "YVS Integration Status")
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
        }
        field(8; "Batch Log"; Text[2048])
        {
            Caption = 'Batch Log';
            DataClassification = SystemMetadata;
        }
        field(9; "Record Count"; Integer)
        {
            Caption = 'Record Count';
            DataClassification = SystemMetadata;
        }
        field(10; "Transaction Date Time"; DateTime)
        {
            Caption = 'Transaction Date Time';
            DataClassification = SystemMetadata;
        }
        field(11; Processing; Boolean)
        {
            Caption = 'Processing';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Batch Key", "API Key") { Clustered = true; }
        key(ApiDate; "API Key", "Batch Key", "Transaction Date Time") { }
    }

    procedure SetRequestJson(JsonText: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Request JSON");
        "Request JSON".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(JsonText);
    end;

    procedure GetRequestJson(): Text
    var
        InStr: InStream;
        Result: Text;
    begin
        CalcFields("Request JSON");
        if not "Request JSON".HasValue() then
            exit('');
        "Request JSON".CreateInStream(InStr, TextEncoding::UTF8);
        InStr.ReadText(Result);
        exit(Result);
    end;

    procedure SetResponseJson(JsonText: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Response JSON");
        "Response JSON".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(JsonText);
    end;

    procedure GetResponseJson(): Text
    var
        InStr: InStream;
        Result: Text;
    begin
        CalcFields("Response JSON");
        if not "Response JSON".HasValue() then
            exit('');
        "Response JSON".CreateInStream(InStr, TextEncoding::UTF8);
        InStr.ReadText(Result);
        exit(Result);
    end;
}
