// TEMPLATE: Integration engine for handling API request and response logging.

codeunit 50129 "YVS Integration Engine"
{
    var
        CurrentApiKey: Enum "YVS API Key";
        CurrentBatchKey: Guid;
        StartTime: DateTime;
        Failed2Sync: Label 'Failed to sync records. Please review the data and try again.';


    procedure UpdateIntegrationHistoryStatus(ApiKey: Enum "YVS API Key";
        BatchKey: Guid; IntegrationStatus: Enum "YVS Integration Status")
    var
        History: Record "YVS Integration History";
    begin
        History.SetRange("API Key", ApiKey);
        History.SetRange("Batch Key", BatchKey);
        History.ModifyAll("Batch Status", IntegrationStatus);
    end;

    /// <summary>
    /// Updates the status of the integration batch with the provided information.
    /// </summary>
    /// <param name="ApiKey">The API key identifying the integration.</param>
    /// <param name="BatchKey">The batch key for the integration batch.</param>
    /// <param name="TransactionDateTime">The date and time of the transaction.</param>
    /// <param name="RequestJson">The JSON request payload.</param>
    /// <param name="ResponseJson">The JSON response payload.</param>
    /// <param name="Status">The final status of the integration batch.</param>
    /// <param name="ErrorMsg">Any error message associated with the integration batch.</param>
    /// <param name="RecordCount">The number of records processed in the integration batch.</param>
    procedure UpdateIntegrationHistory(ApiKey: Enum "YVS API Key";
        BatchKey: Guid; TransactionDateTime: DateTime; RequestJson: Text;
        ResponseJson: Text; IntegrationStatus: Enum "YVS Integration Status";
        IntegrationLog: Text; RecordCount: Integer)
    var
        History: Record "YVS Integration History";
    begin
        if not History.Get(ApiKey, BatchKey) then
            exit;

        History.SetRequestJson(MaskSecret(RequestJson));
        History.SetResponseJson(MaskSecret(ResponseJson));
        History."Batch Status" := IntegrationStatus;
        History."Batch Log" := CopyStr(IntegrationLog, 1, 2048);
        History."Record Count" := RecordCount;
        History."Transaction Date Time" := CurrentDateTime();
        History.Processing := false;
        History.Modify(true);
    end;

    /// <summary>
    /// Creates a new integration history record with the provided information.
    /// </summary>
    /// <param name="ApiKey">The API key identifying the integration.</param>
    /// <param name="BatchKey">The batch key for the integration batch.</param>
    /// <param name="Direction">The direction of the integration (inbound or outbound).</param>
    /// <param name="TransDateTime">The date and time of the transaction.</param>
    /// <param name="TotalRecords">The total number of records in the integration batch.</param>
    /// <param name="JsonRequest">The JSON request payload.</param>
    /// <param name="JsonResponse">The JSON response payload.</param>
    /// <param name="BatchLog">Any log information associated with the integration batch.</param>
    procedure CreateIntegrationHistory(
        ApiKey: Enum "YVS API Key";
        BatchKey: Guid; Direction: Enum "YVS Integration Direction";
        TransDateTime: DateTime;
        TotalRecords: Integer;
        JsonRequest: Text;
        JsonResponse: Text;
        BatchLog: Text)
    var
        History: Record "YVS Integration History";
    begin
        History.Init();
        History."API Key" := ApiKey;
        History.Direction := Direction;
        History."Batch Key" := BatchKey;

        History."Batch Status" := History."Batch Status"::"Pending";
        if JsonRequest <> '' then
            History.SetRequestJson(MaskSecret(JsonRequest));
        if JsonResponse <> '' then
            History.SetResponseJson(MaskSecret(JsonResponse));
        History."Transaction Date Time" := TransDateTime;
        History."Record Count" := TotalRecords;
        if TotalRecords = 0 then
            History."Batch Log" := BatchLog <> '' ? CopyStr(BatchLog, 1, 2048) : Failed2Sync;

        History.Insert(true);
    end;

    procedure GetBatchKey(): Guid
    begin
        exit(CurrentBatchKey);
    end;

    procedure GetAPIKey(): Enum "YVS API Key"
    begin
        exit(CurrentApiKey);
    end;

    /// Masks secret values before persisting JSON.
    /// Extend per partner contract: Authorization, client_secret, api_key, password, refresh_token.
    local procedure MaskSecret(Payload: Text): Text
    begin
        // TODO: replace secret values with '***' before storage.
        // Never persist raw credentials or tokens.
        exit(Payload);
    end;

    procedure BuildRequestJson(BatchKey: Guid; Data: JsonArray): JsonObject
    var
        RequestObject: JsonObject;
    begin
        RequestObject.Add('legalentityid', CompanyProperty.ID());
        RequestObject.Add('batchkey', BatchKey);
        RequestObject.Add('data', Data);
        exit(RequestObject);
    end;

    procedure BuildResponseJson(BatchKey: Guid; RecordCount: Integer; ErrorMessage: Text): JsonObject
    var
        ResponseObject: JsonObject;
        Result: Text;
    begin
        ResponseObject.Add('legalentityid', CompanyProperty.ID());
        ResponseObject.Add('batchkey', Format(BatchKey));
        ResponseObject.Add('transactiontime', Format(CurrentDateTime()));
        if ErrorMessage = '' then
            ResponseObject.Add('batchstatus', 'success')
        else begin
            ResponseObject.Add('batchstatus', 'error');
            ResponseObject.Add('batchlog', ErrorMessage);
        end;
        exit(ResponseObject);
    end;

    procedure BuildResponseJsonFailed(ErrorMessage: Text): JsonObject
    begin
        exit(BuildResponseJson(CreateGuid(), 0, ErrorMessage));
    end;

    procedure GetGuid(SourceObject: JsonObject; PropertyName: Text; var Result: Guid): Boolean
    var
        Token: JsonToken;
        TextValue: Text;
    begin
        GetText(SourceObject, PropertyName, TextValue);
        exit(Evaluate(Result, TextValue));
    end;

    procedure GetInteger(SourceObject: JsonObject; PropertyName: Text; var Result: Integer): Boolean
    var
        Token: JsonToken;
        TextValue: Text;
    begin
        GetText(SourceObject, PropertyName, TextValue);
        exit(Evaluate(Result, TextValue));
    end;

    procedure GetCode(SourceObject: JsonObject; PropertyName: Text; var Result: Code[20]): Boolean
    var
        Token: JsonToken;
        TextValue: Text;
    begin
        GetText(SourceObject, PropertyName, TextValue);
        Result := CopyStr(TextValue, 1, MaxStrLen(Result));
        exit(true);
    end;

    procedure GetText(SourceObject: JsonObject; PropertyName: Text; var Result: Text): Boolean
    var
        Token: JsonToken;
        TextValue: Text;
    begin
        if not SourceObject.Get(PropertyName, Token) then
            exit(false);
        if not Token.IsValue() then
            exit(false);
        Result := Token.AsValue().AsText();
        exit(true);
    end;

    procedure GetArray(SourceObject: JsonObject; PropertyName: Text; var Result: JsonArray): Boolean
    var
        Token: JsonToken;
    begin
        if not SourceObject.Get(PropertyName, Token) then
            exit(false);
        if not Token.IsArray() then
            exit(false);
        Result := Token.AsArray();
        exit(true);
    end;
}