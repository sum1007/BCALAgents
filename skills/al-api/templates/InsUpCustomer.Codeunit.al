// TEMPLATE: Inbound InsUpCustomer request handler.
// Re-prefix {PREFIX} and re-ID from the project ledger before materializing.
// The public procedure receives the raw request JSON and writes one typed detail
// row for each object in the data array.

codeunit 50131 "VAS InsUpCustomer"
{
    procedure ProcessRequest(RequestJson: Text): Boolean
    var
        LogMgt: Codeunit "VAS Integration Log Mgt.";
        RequestObject: JsonObject;
        DataArray: JsonArray;
        BatchKey: Guid;
        RequestBatchKey: Guid;
        LegalEntityId: Code[20];
        ApiKey: Integer;
        RecordCount: Integer;
        ErrorMessage: Text;
        Status: Enum "VAS Integration Status";
        ResponseJson: Text;
    begin
        ApiKey := Codeunit::"VAS InsUpCustomer";
        BatchKey := LogMgt.StartLog(
            ApiKey,
            Enum::"VAS Integration Direction"::"Inbound");

        if not RequestObject.ReadFrom(RequestJson) then begin
            ErrorMessage := 'The request body is not valid JSON.';
            LogMgt.FinishLog(
                RequestJson,
                ResponseJson,
                Enum::"VAS Integration Status"::"Error",
                ErrorMessage,
                0);
            exit(false);
        end;

        if not GetGuid(RequestObject, 'batchkey', RequestBatchKey) then begin
            ErrorMessage := 'The request property batchkey is missing or invalid.';
            LogMgt.FinishLog(
                RequestJson,
                BuildResponseJson(BatchKey, 0, ErrorMessage),
                Enum::"VAS Integration Status"::"VAS Error",
                ErrorMessage,
                0);
            exit(false);
        end;

        if not GetText(RequestObject, 'legalentityid', LegalEntityId) then begin
            ErrorMessage := 'The request property legalentityid is missing.';
            LogMgt.FinishLog(
                RequestJson,
                BuildResponseJson(BatchKey, 0, ErrorMessage),
                Enum::"VAS Integration Status"::"VAS Error",
                ErrorMessage,
                0);
            exit(false);
        end;

        if not GetArray(RequestObject, 'data', DataArray) then begin
            ErrorMessage := 'The request property data is missing or is not an array.';
            LogMgt.FinishLog(
                RequestJson,
                BuildResponseJson(BatchKey, 0, ErrorMessage),
                Enum::"VAS Integration Status"::"VAS Error",
                ErrorMessage,
                0);
            exit(false);
        end;

        if not InsertDetailRows(
            DataArray,
            ApiKey,
            BatchKey,
            RequestBatchKey,
            LegalEntityId,
            RecordCount,
            ErrorMessage)
        then begin
            LogMgt.FinishLog(
                RequestJson,
                BuildResponseJson(BatchKey, RecordCount, ErrorMessage),
                Enum::"VAS Integration Status"::"Error",
                ErrorMessage,
                RecordCount);
            exit(false);
        end;

        Status := Enum::"VAS Integration Status"::"VAS Success";
        LogMgt.FinishLog(
            RequestJson,
            BuildResponseJson(BatchKey, RecordCount, ''),
            Status,
            '',
            RecordCount);
        exit(true);
    end;

    local procedure InsertDetailRows(
        DataArray: JsonArray;
        ApiKey: Integer;
        BatchKey: Guid;
        RequestBatchKey: Guid;
        LegalEntityId: Code[20];
        var RecordCount: Integer;
        var ErrorMessage: Text): Boolean
    var
        DataToken: JsonToken;
        DataObject: JsonObject;
        DetailLog: Record "VAS InsUpCustomer Log";
        IntegrationKey: Guid;
        CustomerId: Code[20];
        CustomerName: Text[100];
        LineNumber: Integer;
        Index: Integer;
    begin
        if DataArray.Count() = 0 then
            exit(true);

        for Index := 0 to DataArray.Count() - 1 do begin
            DataToken := DataArray.Get(Index);
            if not DataToken.IsObject() then begin
                ErrorMessage := StrSubstNo('The data item at index %1 is not an object.', Index);
                exit(false);
            end;

            DataObject := DataToken.AsObject();
            if not GetGuid(DataObject, 'integrationkey', IntegrationKey) then begin
                ErrorMessage := StrSubstNo('The data item at index %1 has an invalid integrationkey.', Index);
                exit(false);
            end;
            if not GetInteger(DataObject, 'linenumber', LineNumber) then begin
                ErrorMessage := StrSubstNo('The data item at index %1 has an invalid linenumber.', Index);
                exit(false);
            end;
            if not GetText(DataObject, 'customerid', CustomerId) then begin
                ErrorMessage := StrSubstNo('The data item at index %1 is missing customerid.', Index);
                exit(false);
            end;
            if not GetText(DataObject, 'customername', CustomerName) then begin
                ErrorMessage := StrSubstNo('The data item at index %1 is missing customername.', Index);
                exit(false);
            end;

            DetailLog.Init();
            DetailLog."API Key" := ApiKey;
            DetailLog."Batch Key" := BatchKey;
            DetailLog."Integration Key" := IntegrationKey;
            DetailLog."VAS Request Batch Key" := RequestBatchKey;
            DetailLog."VAS Line Number" := LineNumber;
            DetailLog."VAS Customer Id" := CustomerId;
            DetailLog."VAS Customer Name" := CustomerName;
            DetailLog."VAS Legal Entity Id" := LegalEntityId;
            DetailLog."Integration Status" := DetailLog."Integration Status"::"VAS Success";
            DetailLog.Insert(true);
            RecordCount += 1;
        end;

        exit(true);
    end;
}
