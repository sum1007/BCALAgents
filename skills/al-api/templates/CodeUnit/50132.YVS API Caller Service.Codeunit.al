/// <summary>
/// Service for calling external APIs using the defined API keys and handling the request and response.
/// </summary>
codeunit 50132 "YVS API Caller Service"
{
    [TryFunction]
    procedure CallAPI(APIKey: Enum "YVS API Key"; JsonPayload: Text; var ResponseText: Text)
    var
        ExternalAppDef: Record "YVS External App Definition";
        APICallerEngine: Codeunit "YVS API Caller Engine";
        RequestHeaderDictionary: Codeunit "Dictionary Wrapper";
        AccessToken: SecretText;
    begin
        if ExternalAppDef.Get(APIKey) then begin
            case ExternalAppDef."OAuth Type" of
                ExternalAppDef."OAuth Type"::"Client Credentials":
                    begin
                        // Get the access token using the API caller engine
                        AccessToken := APICallerEngine.GetAccessToken(ExternalAppDef);
                        ResponseText := APICallerEngine.SendRequestWithBearerToken(ExternalAppDef, JsonPayload, AccessToken);
                    end;
            end;
        end else begin
            Error('External app definition not found for API key %1', APIKey);
            // Handle the case where the external app definition is not found
        end;
    end;
}