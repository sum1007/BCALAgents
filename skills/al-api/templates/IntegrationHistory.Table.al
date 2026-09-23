// TEMPLATE: Level 1 shared header table — one row per API call.
// Generate ONCE per app (idempotent). Re-prefix {PREFIX} and re-ID from the Ledger (Table sub-range).
// API Key  = Integer object id of the API object (Page::"..." / Codeunit::"...").
// Batch Key = Guid from CreateGuid(), shared with every detail row of the run.

table 50103 "VAS Integration History"
{
    Caption = 'VAS Integration History';
    DataClassification = SystemMetadata;
    LookupPageId = "VAS Integration History List";
    DrillDownPageId = "VAS Integration History List";

    fields
    {
        field(1; "API Key"; Integer)
        {
            Caption = 'API Key';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID";

            trigger OnValidate()
            begin
                "API Name" := CopyStr(GetObjectName("API Key"), 1, 100);
            end;
        }
        field(2; "API Name"; Text[100])
        {
            Caption = 'API Name';
            DataClassification = SystemMetadata;
        }
        field(3; Direction; Enum "VAS Integration Direction")
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
        field(7; "Batch Status"; Enum "VAS Integration Status")
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
