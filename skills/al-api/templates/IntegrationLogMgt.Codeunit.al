// TEMPLATE: Logging codeunit for the Level 1 header.
// Generate ONCE per app. Re-prefix {PREFIX} and re-ID from the Ledger (Codeunit sub-range).
//
// Contract:
//   BatchKey := StartLog(ApiKey, Direction, DetailTableNo, EndpointUrl);   // header, Status = Pending
//      -> caller inserts typed detail rows using BatchKey
//   FinishLog(RequestJson, ResponseJson, HttpStatus, Status, ErrorMsg, RecordCount);
//
// On failure the caller MUST still call FinishLog with Status = Error.

codeunit 50129 "VAS Integration Log Mgt."
{
    var
        CurrentApiKey: Integer;
        CurrentBatchKey: Guid;
        StartTime: DateTime;

    /// Creates the header row and returns the GUID batch key shared by all detail rows.
    /// ApiKey must be an object id, e.g. Codeunit::"VAS Misa Invoice Sync" or Page::"VAS Api Customers".
    procedure StartLog(ApiKey: Integer; Direction: Enum "VAS Integration Direction")
    var
        History: Record "VAS Integration History";
    begin
        CurrentBatchKey := CreateGuid();
        CurrentApiKey := ApiKey;

        History.Init();
        History."API Key" := ApiKey;
        History.Direction := Direction;
        History."Batch Key" := CurrentBatchKey;
        History."Batch Status" := History."Batch Status"::"Pending";

        History.Insert(true);
    end;

    /// Persists request/response JSON and the final status/duration on the header row.
    procedure FinishLog(APIKey: Integer; BatchKey: Guid; RequestJson: Text; ResponseJson: Text; Status: Enum "VAS Integration Status"; ErrorMsg: Text; RecordCount: Integer)
    var
        History: Record "VAS Integration History";
    begin
        if not History.Get(APIKey, BatchKey) then
            exit;

        History.SetRequestJson(MaskSecret(RequestJson));
        History.SetResponseJson(MaskSecret(ResponseJson));
        History."Batch Status" := Status;
        History."Batch Log" := CopyStr(ErrorMsg, 1, 2048);
        History."Record Count" := RecordCount;
        History."Transaction Date Time" := CurrentDateTime();
        History.Modify(true);
    end;

    procedure GetBatchKey(): Guid
    begin
        exit(CurrentBatchKey);
    end;

    procedure GetAPIKey(): Integer
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
}
