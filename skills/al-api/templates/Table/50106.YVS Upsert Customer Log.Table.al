// TEMPLATE: Per-API detail log for the InsUpCustomer inbound contract.
// Generate one table per API. Re-prefix {PREFIX} and re-ID from the project ledger.
// The codeunit writes one typed row for each item in the request data array.

table 50106 "YVS UpSert Customer Log"
{
    Caption = 'YVS UpSert Customer Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "API Key"; Enum "YVS API Key")
        {
            Caption = 'API Key';
            DataClassification = SystemMetadata;
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
        field(12; "YVS Customer Id"; Code[20])
        {
            Caption = 'Customer Id';
            DataClassification = CustomerContent;
        }
        field(13; "YVS Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(14; "YVS Legal Entity Id"; Code[20])
        {
            Caption = 'Legal Entity Id';
            DataClassification = CustomerContent;
        }
        field(90; "Integration Status"; Enum "YVS Integration Status")
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
    }

    procedure ValidateData()
    var
        IntegrationLog: Text;
    begin
        if "YVS Customer Id" = '' then
            IntegrationLog := 'YVS Customer Id is missing.';

        if IsNullGuid("Integration Key") then
            IntegrationLog := 'Integration Key is missing.';

        if IntegrationLog <> '' then begin
            "Integration Status" := "Integration Status"::Failed;
            "Integration Log" := IntegrationLog;
        end
    end;

    procedure ExistIntegrationKey(APIKey: Enum "YVS API Key"; BatchKey: Guid; IntegrationKey: Guid): Boolean
    var
        Rec: Record "YVS UpSert Customer Log";
    begin
        exit(Rec.Get(APIKey, BatchKey, IntegrationKey));
    end;
}