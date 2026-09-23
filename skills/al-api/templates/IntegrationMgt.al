/// <summary>
/// 
/// </summary>
codeunit 50129 "VAS Integration Mgt."
{
    var
        CurrentApiKey: Integer;
        CurrentBatchKey: Guid;
        StartTime: DateTime;

    procedure BuildRequestJson(BatchKey: Guid; Data: JsonArray): RequestObject
    var
        RequestObject: JsonObject;
    begin
        RequestObject := JsonObject();
        RequestObject.Add('legalentityid', CompanyProperty.ID());
        RequestObject.Add('batchkey', BatchKey);
        RequestObject.Add('data', Data);
        exit(RequestObject);
    end;

    procedure BuildResponseJson(BatchKey: Guid; RecordCount: Integer; ErrorMessage: Text): RequestObject
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
