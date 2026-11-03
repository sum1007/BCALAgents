page 50125 "YVS Ext. App Definition Card"
{
    PageType = Card;
    SourceTable = "YVS External App Definition";
    Caption = 'YVS External App Definition';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(YVSGeneral)
            {
                Caption = 'General';

                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the API key for this external application.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the external application.';
                }
                field(URL; Rec.URL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the URL of the external application.';
                }
                field("Http Request Type"; Rec."Http Request Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the HTTP method used by the external application.';
                }
                field("OAuth Type"; Rec."OAuth Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the authentication type used by the external application.';
                    trigger OnValidate()
                    begin
                        case Rec."OAuth Type" of
                            Rec."OAuth Type"::"Client Credentials":
                                begin
                                    ClientCredentialsMandatory := true;
                                    ClientCredentialsVisible := false;

                                    AccessTokenMandatory := false;
                                    UserNameMandatory := false;
                                    UserPasswordMandatory := false;
                                    AccessTokenVisible := true;
                                    UserPasswordVisible := true;
                                end;
                            Rec."OAuth Type"::"Access Token",
                            Rec."OAuth Type"::XAPIKey:
                                begin
                                    AccessTokenMandatory := true;
                                    AccessTokenVisible := false;
                                    ClientCredentialsMandatory := false;
                                    ClientCredentialsVisible := true;
                                    UserNameMandatory := false;
                                    UserPasswordMandatory := false;
                                    UserPasswordVisible := true;
                                end;
                            else
                                ;
                        end;
                    end;
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the external application is active.';
                }
                field("Time Out"; Rec."Time Out")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the timeout, in milliseconds, for requests to the external application.';
                }
            }
            group(YVSAuthentication)
            {
                Caption = 'Authentication';

                group(YVSClientCredentials)
                {
                    Caption = 'Client Credentials Settings';
                    Visible = ClientCredentialsVisible;

                    field("OAuth URL"; Rec."OAuth URL")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the OAuth endpoint URL.';
                        ShowMandatory = ClientCredentialsMandatory;
                    }
                    field("OAuth Client ID"; Rec."OAuth Client ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the OAuth client ID.';
                        ShowMandatory = ClientCredentialsMandatory;
                    }
                    field("OAuth Client Secret"; Rec."OAuth Client Secret")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the OAuth client secret.';
                        ShowMandatory = ClientCredentialsMandatory;
                    }
                }

                field("Access Token"; Rec."Access Token")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the access token.';
                    Visible = AccessTokenVisible;
                    ShowMandatory = AccessTokenMandatory;
                }
                group(YVSUserNamePassword)
                {
                    Caption = 'User Name and Password Settings';
                    Visible = UserPasswordVisible;

                    field("User Name"; Rec."User Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the user name used for authentication.';
                        ShowMandatory = UserNameMandatory;
                    }
                    field("User Password"; Rec."User Password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the password used for authentication.';
                        ShowMandatory = UserPasswordMandatory;
                    }
                }
            }
        }
    }

    var
        ClientCredentialsMandatory: Boolean;
        AccessTokenMandatory: Boolean;
        UserPasswordMandatory: Boolean;
        ClientCredentialsVisible: Boolean;
        AccessTokenVisible: Boolean;
        UserPasswordVisible: Boolean;
        UserNameMandatory: Boolean;
}