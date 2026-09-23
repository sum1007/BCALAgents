// TEMPLATE: Inbound API page + logging of received records.
// Generate ONE PER inbound API. Re-prefix {PREFIX} and re-ID from the Ledger (Page sub-range).
//
// API Key = this page's own object id, so the log points back to the endpoint that received the data.
// Every received record is written to the per-API detail table under the same GUID batch key.

page 50111 "VAS Api Customers"
{
    PageType = API;
    APIPublisher = 'votiva';
    APIGroup = 'vas';
    APIVersion = 'v1.0';
    EntityName = 'vasCustomer';
    EntitySetName = 'vasCustomers';
    ODataKeyFields = SystemId;
    SourceTable = Customer;
    DelayedInsert = true;
    Caption = 'VAS Api Customers';
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(displayName; Rec.Name) { Caption = 'Name'; }
                field(vasTaxCode; Rec."VAS Tax Code") { Caption = 'Tax Code'; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        LogInbound(Rec, Enum::"VAS Integration Status"::"VAS Success", '');
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        LogInbound(Rec, Enum::"VAS Integration Status"::"VAS Success", '');
        exit(true);
    end;

    /// Writes the header (once per call) and one typed detail row for the received record.
    local procedure LogInbound(var Cust: Record Customer; Status: Enum "VAS Integration Status"; ErrorMsg: Text)
    var
        LogMgt: Codeunit "VAS Integration Log Mgt.";
        DetailLog: Record "VAS Api Customer Log";
        ApiKey: Integer;
        BatchKey: Guid;
        PayloadJson: Text;
    begin
        ApiKey := Page::"VAS Api Customers";

        BatchKey := LogMgt.StartLog(
            ApiKey,
            Enum::"VAS Integration Direction"::"Inbound");

        DetailLog.Init();
        DetailLog."API Key" := ApiKey;
        DetailLog."Batch Key" := BatchKey;
        DetailLog."Integration Key" := CreateGuid();
        DetailLog."VAS Customer No." := Cust."No.";
        DetailLog."VAS Customer Name" := CopyStr(Cust.Name, 1, 100);
        DetailLog."VAS Tax Code" := Cust."VAS Tax Code";
        DetailLog."Integration Status" := Status;
        DetailLog."Integration Log" := CopyStr(ErrorMsg, 1, 2048);
        DetailLog.Insert(true);

        PayloadJson := BuildPayloadJson(Cust);
        LogMgt.FinishLog(PayloadJson, '', 200, Status, ErrorMsg, 1);
    end;

    local procedure BuildPayloadJson(var Cust: Record Customer): Text
    var
        JsonObj: JsonObject;
        Result: Text;
    begin
        JsonObj.Add('number', Cust."No.");
        JsonObj.Add('displayName', Cust.Name);
        JsonObj.Add('vasTaxCode', Cust."VAS Tax Code");
        JsonObj.WriteTo(Result);
        exit(Result);
    end;
}
