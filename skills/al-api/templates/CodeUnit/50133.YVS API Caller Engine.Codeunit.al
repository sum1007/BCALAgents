codeunit 50133 "YVS API Caller Engine"
{
    procedure SendRequest(ExternalAppDef: Record "YVS External App Definition"; JsonPayload: Text): Text
    var
        AccessToken: SecretText;
    begin
        exit(SendRequest(
            JsonPayload,
            ExternalAppDef."Http Request Type",
            Format(ExternalAppDef.URL),
            GetDefaultContentHeaderDictionary(true),
            ExternalAppDef."Time Out",
            GetDefaultRequestHeaderDictionary(),
            AccessToken));
    end;

    procedure SendRequestWithBearerToken(ExternalAppDef: Record "YVS External App Definition"; JsonPayload: Text; AccessToken: SecretText): Text
    var
        BearerToken: SecretText;
    begin
        BearerToken := SecretStrSubstNo('Bearer %1', AccessToken);
        exit(SendRequest(
            JsonPayload,
            ExternalAppDef."Http Request Type",
            Format(ExternalAppDef.URL),
            GetDefaultContentHeaderDictionary(true),
            ExternalAppDef."Time Out",
            GetDefaultRequestHeaderDictionary(),
            BearerToken));
    end;

    procedure SendRequest(ContentToSend: Variant;
                        RequestMethod: Enum "Http Request Type";
                        RequestUri: Text;
                        DictionaryContentHeaders: Codeunit "Dictionary Wrapper";
                        HttpTimeout: integer;
                        DictionaryRequestHeaders: Codeunit "Dictionary Wrapper";
                        AccessToken: SecretText): Text
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        Content: HttpContent;
        ResponseText: Text;
        ErrorBodyContent: Text;
        TextContent: Text;
        InStreamContent: InStream;
        JsonObject: JsonObject;
        i: Integer;
        KeyVariant: Variant;
        ValueVariant: Variant;
        HasContent: Boolean;
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
    begin
        case true of
            ContentToSend.IsText():
                begin
                    TextContent := ContentToSend;
                    Content.WriteFrom(TextContent);
                    HasContent := true;
                end;
            ContentToSend.IsInStream():
                begin
                    InStreamContent := ContentToSend;
                    Content.WriteFrom(InStreamContent);
                    HasContent := true;
                end;
            else
                Error(UnsupportedContentToSendErrLbl);
        end;

        if HasContent then
            Request.Content := Content;

        ContentHeaders.Clear();
        Request.Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains(ContentTypeKeyLbl) then
            ContentHeaders.Remove(ContentTypeKeyLbl);

        for i := 0 to DictionaryContentHeaders.Count() do
            if DictionaryContentHeaders.TryGetKeyValue(i, KeyVariant, ValueVariant) then
                ContentHeaders.Add(Format(KeyVariant), Format(ValueVariant));

        Request.SetRequestUri(RequestUri);
        Request.Method := Format(RequestMethod);

        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Add(AuthorizationLbl, AccessToken);
        for i := 0 to DictionaryRequestHeaders.Count() do
            if DictionaryRequestHeaders.TryGetKeyValue(i, KeyVariant, ValueVariant) then
                RequestHeaders.Add(Format(KeyVariant), Format(ValueVariant));

        if HttpTimeout <> 0 then
            Client.Timeout(HttpTimeout);

        Client.Send(Request, Response);

        Response.Content().ReadAs(ResponseText);
        if not Response.IsSuccessStatusCode() then begin
            Response.Content().ReadAs(ErrorBodyContent);
            Error(RequestErrLbl, Format(RequestMethod), RequestUri, Response.HttpStatusCode(), ErrorBodyContent);
        end;

        exit(ResponseText);
    end;

    procedure GetAccessToken(ExternalAppDef: Record "YVS External App Definition"): SecretText
    var
        ContentHeaderDictionary: Codeunit "Dictionary Wrapper";
        RequestHeaderDictionary: Codeunit "Dictionary Wrapper";
        JsonBodyRequest: Text;
        JsonRequestObject: JsonObject;
        ResponseText: Text;
        ResponseResultJsonObject: JsonObject;
        JsonToken: JsonToken;
        DictionaryValue: Variant;
        AccessToken: SecretText;
    begin
        JsonRequestObject.Add('grant_type', Format(ExternalAppDef."OAuth Type"));
        JsonRequestObject.Add('client_id', Format(ExternalAppDef."OAuth Client ID"));
        JsonRequestObject.Add('client_secret', Format(ExternalAppDef."OAuth Client Secret"));

        JsonRequestObject.WriteTo(JsonBodyRequest);
        ContentHeaderDictionary := GetDefaultContentHeaderDictionary(true);
        RequestHeaderDictionary := GetDefaultRequestHeaderDictionary();
        ResponseText := SendRequest(JsonBodyRequest,
        Enum::"Http Request Type"::POST,
        Format(ExternalAppDef."OAuth URL"),
        ContentHeaderDictionary,
        0,
        RequestHeaderDictionary,
        AccessToken);

        if ResponseText <> '' then begin
            ResponseResultJsonObject.ReadFrom(ResponseText);
            if ResponseResultJsonObject.Get('access_token', JsonToken) then begin
                AccessToken := JsonToken.AsValue().AsText();
            end;
        end;
        exit(AccessToken);
    end;

    procedure GetDefaultContentHeaderDictionary(JsonContentType: Boolean) ContentHeaderDictionary: Codeunit "Dictionary Wrapper";
    begin
        if JsonContentType then
            ContentHeaderDictionary.Set(ContentTypeKeyLbl, JsonContentTypeLbl)
        else
            ContentHeaderDictionary.Set(ContentTypeKeyLbl, SOAP11XMLContentTypeLbl);
    end;

    procedure GetDefaultRequestHeaderDictionary() RequestHeaderDictionary: Codeunit "Dictionary Wrapper";
    begin
        RequestHeaderDictionary.Set(AcceptKeyLbl, '*/*');
    end;

    var
        SOAP11NamespaceURILbl: Label 'http://schemas.xmlsoap.org/soap/envelope/', Locked = true;
        SOAP12NamespaceUriLbl: Label 'http://www.w3.org/2003/05/soap-envelope', Locked = true;
        W3BaseNamespaceUriLbl: Label 'http://tempuri.org/', Locked = true;
        SOAP11XMLContentTypeLbl: Label 'text/xml; charset=utf-8', Locked = true;
        SOAP12XMLContentTypeLbl: Label 'application/soap+xml; charset=utf-8', Locked = true;
        SOAP12VersionLbl: Label 'soap12', Locked = true;
        W3ActionUriLbl: Label 'tempconvert.asmx', Locked = true;
        LocalXPathSignatureLbl: Label '[local-name()="%1"]', Locked = true;
        LocalXPathSeparatorLbl: Label '//*', Locked = true;
        BodyXPathLbl: Label '/*[local-name()="Envelope"]/*[local-name()="Body"]', Locked = true;
        ErrorLbl: Label 'Error', Locked = true;
        JsonContentTypeLbl: Label 'application/json', Locked = true;
        FormUrlEncodedContentTypeLbl: Label 'application/x-www-form-urlencoded', Locked = true;

        RequestErrLbl: Label 'API call failed [%1 %2] %3: %4', Comment = '%1 = HttpMethod, %2 = URL, %3 = HttpStatusCode, %4 = ResponseBody';
        UnsupportedContentToSendErrLbl: Label 'Unsuportted content to send.';
        ContentTypeKeyLbl: Label 'Content-Type', Locked = true;
        AcceptKeyLbl: Label 'Accept', Locked = true;
        CookieLbl: Label 'Cookie', Locked = true;
        AuthorizationLbl: Label 'Authorization', Locked = true;
        BearerLbl: Label 'Bearer %1', Locked = true;
}