// TEMPLATE: Per-API detail log for the InsUpCustomer inbound contract.
// Generate one table per API. Re-prefix {PREFIX} and re-ID from the project ledger.
// The codeunit writes one typed row for each item in the request data array.

table 50107 "YVS Sync Sales Invoice Log"
{
    Caption = 'YVS Sync Sales Invoice Log';
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
        field(11; "Line Number"; Integer)
        {
            Caption = 'Line Number';
            DataClassification = SystemMetadata;
        }
        field(4; "Ref System Id"; Guid)
        {
            Caption = 'Ref System Id';
            DataClassification = SystemMetadata;
        }
        field(12; "YVS Document No"; Code[20])
        {
            Caption = 'Document No';
            DataClassification = CustomerContent;
        }
        field(13; "YVS Customer No"; Text[100])
        {
            Caption = 'Customer No';
            DataClassification = CustomerContent;
        }
        field(15; "YVS Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(16; "YVS Amount"; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(17; "YVS Invoice Date"; Date)
        {
            Caption = 'Invoice Date';
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

    procedure InitializeFromCommon(SalesInvHdr: Record "Sales Invoice Header")
    begin
        "YVS Document No" := SalesInvHdr."No.";
        "YVS Customer No" := SalesInvHdr."Sell-to Customer No.";
        "YVS Customer Name" := CopyStr(SalesInvHdr."Sell-to Customer Name", 1, 100);
        "YVS Invoice Date" := SalesInvHdr."Posting Date";
        "YVS Amount" := SalesInvHdr.Amount;
        "YVS Legal Entity Id" := SalesInvHdr.CurrentCompany();
        "Ref System Id" := SalesInvHdr.SystemId;
    end;

    procedure ExistPendingRecord(ApiKey: Enum "YVS API Key"; RefSystemId: Guid): Boolean
    var
        DetailLog: Record "YVS Sync Sales Invoice Log";
        IntegrationHist: Record "YVS Integration History";
    begin
        DetailLog.SetRange("API Key", ApiKey);
        DetailLog.SetRange("Ref System Id", RefSystemId);
        DetailLog.SetFilter("Integration Status", '%1 | %2', DetailLog."Integration Status"::"Pending", DetailLog."Integration Status"::"Failed");
        exit(DetailLog.FindFirst());
    end;
}