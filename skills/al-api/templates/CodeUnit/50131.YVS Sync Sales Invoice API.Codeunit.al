// TEMPLATE: Outbound sync usage pattern — fully wrapped in the logging layer.
// Generate ONE PER outbound API. Re-prefix {PREFIX} and re-ID from the Ledger.
//
// Handles the synchronization of sales invoices with the external system.

codeunit 50131 "YVS Sync Sales Invoice API"
{
    var
        IntegrationEngine: Codeunit "YVS Integration Engine";

    /// <summary>
    /// Synchronizes the sales invoices with the external system and returns the response text.
    /// </summary>
    /// <param name="SalesInvHdr">The sales invoice header record to be synchronized.</param>
    /// <returns>The response text received from the external system.</returns>
    procedure SyncData(var SalesInvHdr: Record "Sales Invoice Header"): Boolean
    var
        APICallerService: Codeunit "YVS API Caller Service";
        Content: HttpContent;
        Response: HttpResponseMessage;
        BatchKey: Guid;
        TransactionDateTime: DateTime;
        RequestJson: Text;
        ResponseText: Text;
        RecCount: Integer;
        ConnectionErr: Label 'Connection to the partner API failed.';
        HttpErr: Label 'Partner API returned %1.', Comment = '%1 = HTTP status code';
        IntegrationLog: Text;
    begin
        BatchKey := CreateGuid();
        TransactionDateTime := CurrentDateTime();

        RecCount := WriteLog(SalesInvHdr, BatchKey);

        RequestJson := BuildRequestPayload(Enum::"YVS API Key"::"Sync Sales Invoice", BatchKey);

        if RecCount > 0 then begin
            IntegrationEngine.CreateIntegrationHistory(
                Enum::"YVS API Key"::"Sync Sales Invoice",
                BatchKey,
                Enum::"YVS Integration Direction"::"Outbound",
                CurrentDateTime(),
                RecCount,
                RequestJson,
                '',
                ''
            );
            if not APICallerService.CallAPI(Enum::"YVS API Key"::"Sync Sales Invoice", RequestJson, ResponseText) then
                IntegrationLog := GetLastErrorText();

            if ResponseText <> '' then begin
                IntegrationEngine.UpdateIntegrationHistory(Enum::"YVS API Key"::"Sync Sales Invoice", BatchKey, TransactionDateTime, RequestJson, ResponseText, Enum::"YVS Integration Status"::"Success", '', RecCount);
            end else begin
                IntegrationEngine.UpdateIntegrationHistory(Enum::"YVS API Key"::"Sync Sales Invoice", BatchKey, TransactionDateTime, RequestJson, ResponseText, Enum::"YVS Integration Status"::"Failed",
                    StrSubstNo(HttpErr, ''), RecCount);
            end;
        end;

        exit(true);
    end;

    /// <summary>
    /// Inserts one typed detail row per record in the sales invoice header table.
    /// </summary>
    /// <param name="SalesInvHdr">The sales invoice header record to be logged.</param>
    /// <param name="BatchKey">The batch key for the current synchronization batch.</param>
    /// <returns>The number of detail rows inserted.</returns>
    local procedure WriteLog(var SalesInvHdr: Record "Sales Invoice Header"; BatchKey: Guid): Integer
    var
        DetailLog: Record "YVS Sync Sales Invoice Log";
        LineNo: Integer;
    begin
        if SalesInvHdr.FindSet() then
            repeat
                if DetailLog.ExistPendingRecord(Enum::"YVS API Key"::"Sync Sales Invoice", SalesInvHdr.SystemId) then
                    continue;
                LineNo += 1;
                DetailLog.Init();
                DetailLog.InitializeFromCommon(SalesInvHdr);

                DetailLog."API Key" := DetailLog."API Key"::"Sync Sales Invoice";
                DetailLog."Batch Key" := BatchKey;
                DetailLog."Line Number" := LineNo;
                DetailLog."Integration Key" := CreateGuid();

                DetailLog."Integration Status" := DetailLog."Integration Status"::"Pending";
                DetailLog.Insert(true);
            until SalesInvHdr.Next() = 0;

        exit(LineNo);
    end;

    /// <summary>
    /// Updates the integration log status for the specified batch of sales invoices.
    /// </summary>
    /// <param name="ApiKey">The API key identifying the type of request.</param>
    /// <param name="BatchKey">The batch key for the current synchronization batch.</param>
    /// <param name="IntegrationStatus">The integration status to be set for the batch.</param>
    /// <param name="IntegrationLog">The integration log message associated with the status update.</param>
    /// <param name="ResponseText">The response text received from the external system.</param>
    local procedure UpdateLog(ApiKey: Enum "YVS API Key";
    BatchKey: Guid;
    IntegrationStatus: Enum "YVS Integration Status";
    IntegrationLog: Text;
    ResponseText: Text)
    var
        DetailLog: Record "YVS Sync Sales Invoice Log";
    begin
        DetailLog.SetRange("API Key", ApiKey);
        DetailLog.SetRange("Batch Key", BatchKey);
        DetailLog.ModifyAll("Integration Status", IntegrationStatus);
        DetailLog.ModifyAll("Integration Log", IntegrationLog);

        IntegrationEngine.UpdateIntegrationHistory(ApiKey, BatchKey, CurrentDateTime(), '', ResponseText, IntegrationStatus, IntegrationLog, 0);
    end;

    /// <summary>
    /// Builds the JSON request payload for the given API key and batch key.
    /// </summary>
    /// <param name="ApiKey">The API key identifying the type of request.</param>
    /// <param name="BatchKey">The batch key for the current synchronization batch.</param>
    /// <returns>The JSON payload as a text string.</returns>
    procedure BuildRequestPayload(ApiKey: Enum "YVS API Key"; BatchKey: Guid): Text
    var
        DetailLog: Record "YVS Sync Sales Invoice Log";
        CompanyInfo: Record "Company Information";
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
                JsonObj.Add('invoiceNo', DetailLog."YVS Document No");
                JsonObj.Add('customerCode', DetailLog."YVS Customer No");
                JsonObj.Add('customerName', DetailLog."YVS Customer Name");
                JsonObj.Add('invoiceDate', Format(DetailLog."YVS Invoice Date", 0, 9));
                JsonObj.Add('amount', DetailLog."YVS Amount");
                JsonArr.Add(JsonObj);
            until DetailLog.Next() = 0;

        JsonObj.Add(('batchKey'), Format(BatchKey));
        // Add the legal entity ID from the detail log. get current company id
        CompanyInfo.Get();
        JsonObj.Add('legalentityId', CompanyInfo.SystemId);
        JsonObj.Add('data', JsonArr);
        JsonObj.WriteTo(Result);
        exit(Result);
    end;
}
