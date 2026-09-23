// TEMPLATE: Outbound sync usage pattern — fully wrapped in the logging layer.
// Generate ONE PER outbound API. Re-prefix {PREFIX} and re-ID from the Ledger.
//
// Note: ApiKey is THIS codeunit's own object id, so the log always points back to the caller.

codeunit 50130 "VAS Misa Invoice Sync"
{
    procedure SendInvoices(var SalesInvHdr: Record "Sales Invoice Header"): Boolean
    var
        LogMgt: Codeunit "VAS Integration Log Mgt.";
        Client: HttpClient;
        Content: HttpContent;
        Response: HttpResponseMessage;
        BatchKey: Guid;
        ApiKey: Integer;
        ReqJson: Text;
        RespJson: Text;
        RecCount: Integer;
        ConnectionErr: Label 'Connection to the partner API failed.';
        HttpErr: Label 'Partner API returned %1.', Comment = '%1 = HTTP status code';
    begin
        ApiKey := Codeunit::"VAS Misa Invoice Sync";

        BatchKey := LogMgt.StartLog(
            ApiKey,
            Enum::"VAS Integration Direction"::"VAS Outbound");

        RecCount := WriteDetailRows(SalesInvHdr, ApiKey, BatchKey);

        ReqJson := BuildBatchJson(ApiKey, BatchKey);
        Content.WriteFrom(ReqJson);
        Client.Timeout := 30000;

        if not Client.Post('https://api.misa.example/v1/invoices', Content, Response) then begin
            UpdateBatchStatus(ApiKey, BatchKey, Enum::"VAS Integration Status"::"VAS Error", ConnectionErr);
            LogMgt.FinishLog(ReqJson, '', 0, Enum::"VAS Integration Status"::"VAS Error", ConnectionErr, RecCount);
            exit(false);
        end;

        Response.Content().ReadAs(RespJson);

        if Response.IsSuccessStatusCode() then begin
            UpdateBatchStatus(ApiKey, BatchKey, Enum::"VAS Integration Status"::"VAS Success", '');
            LogMgt.FinishLog(ReqJson, RespJson, Enum::"VAS Integration Status"::"VAS Success", '', RecCount);
        end else begin
            UpdateBatchStatus(ApiKey, BatchKey, Enum::"VAS Integration Status"::"VAS Error",
                StrSubstNo(HttpErr, Response.HttpStatusCode()));
            LogMgt.FinishLog(ReqJson, RespJson, Response.HttpStatusCode(),
                Enum::"VAS Integration Status"::"VAS Error",
                StrSubstNo(HttpErr, Response.HttpStatusCode()), RecCount);
        end;

        exit(Response.IsSuccessStatusCode());
    end;

    /// Inserts one typed detail row per record. Returns the row count.
    local procedure WriteDetailRows(var SalesInvHdr: Record "Sales Invoice Header"; ApiKey: Integer; BatchKey: Guid): Integer
    var
        DetailLog: Record "VAS Misa Invoice Log";
        LineNo: Integer;
    begin
        if SalesInvHdr.FindSet() then
            repeat
                LineNo += 1;
                DetailLog.Init();
                DetailLog."API Key" := ApiKey;
                DetailLog."Batch Key" := BatchKey;
                DetailLog."Integration Key" := CreateGuid();
                DetailLog."VAS Invoice No." := SalesInvHdr."No.";
                DetailLog."VAS Customer Code" := SalesInvHdr."Sell-to Customer No.";
                DetailLog."VAS Customer Name" := CopyStr(SalesInvHdr."Sell-to Customer Name", 1, 100);
                DetailLog."VAS Invoice Date" := SalesInvHdr."Posting Date";
                DetailLog."VAS Amount" := SalesInvHdr.Amount;
                DetailLog."VAS Currency" := SalesInvHdr."Currency Code";
                DetailLog.Status := DetailLog.Status::"VAS Pending";
                DetailLog.Insert(true);
            until SalesInvHdr.Next() = 0;

        exit(LineNo);
    end;

    /// Single pass update so the whole batch shares the final status.
    local procedure UpdateBatchStatus(ApiKey: Integer; BatchKey: Guid; NewStatus: Enum "VAS Integration Status"; ErrorMsg: Text)
    var
        DetailLog: Record "VAS Misa Invoice Log";
    begin
        DetailLog.SetRange("API Key", ApiKey);
        DetailLog.SetRange("Batch Key", BatchKey);
        if DetailLog.FindSet(true) then
            repeat
                DetailLog.Status := NewStatus;
                DetailLog."Error Message" := CopyStr(ErrorMsg, 1, 2048);
                DetailLog.Modify(true);
            until DetailLog.Next() = 0;
    end;

    /// Serializer placeholder — build the request body from the detail rows of this batch.
    local procedure BuildBatchJson(ApiKey: Integer; BatchKey: Guid): Text
    var
        DetailLog: Record "VAS Misa Invoice Log";
        JsonArr: JsonArray;
        DataLine: JsonObject;
        JsonObj: JsonObject;
        Result: Text;
    begin
        DetailLog.SetCurrentKey("API Key", "Batch Key");
        DetailLog.SetRange("API Key", ApiKey);
        DetailLog.SetRange("Batch Key", BatchKey);
        if DetailLog.FindSet() then
            repeat
                Clear(JsonObj);
                JsonObj.Add('integrationKey', DetailLog."Integration Key");
                JsonObj.Add('invoiceNo', DetailLog."VAS Invoice No.");
                JsonObj.Add('customerCode', DetailLog."VAS Customer Code");
                JsonObj.Add('customerName', DetailLog."VAS Customer Name");
                JsonObj.Add('invoiceDate', Format(DetailLog."VAS Invoice Date", 0, 9));
                JsonObj.Add('amount', DetailLog."VAS Amount");
                JsonObj.Add('currency', DetailLog."VAS Currency");
                JsonObj.Add('isVat', DetailLog."VAS Is Vat");
                JsonArr.Add(JsonObj);
            until DetailLog.Next() = 0;

        JsonObj.Add(('batchKey'), Format(BatchKey));
        // Add the legal entity ID from the detail log. get current company id
        JsonObj.Add('legalentityId', CompanyInfo."Company ID");
        JsonObj.Add('data', JsonArr);
        JsonObj.WriteTo(Result);
        exit(Result);
    end;
}
