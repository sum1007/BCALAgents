table 50108 "YVS External App Definition"
{
    Caption = 'YVS External App Definition';
    DataClassification = SystemMetadata;
    LookupPageId = "YVS Ext. App Definition List";
    DrillDownPageId = "YVS Ext. App Definition List";

    fields
    {
        field(1; "API Key"; Enum "YVS API Key")
        {
            Caption = 'API Key';
            DataClassification = SystemMetadata;
        }
        // URL
        field(3; URL; Text[250])
        {
            Caption = 'URL';
            DataClassification = SystemMetadata;
        }
        // HttpMethod
        field(4; "Http Request Type"; Enum "Http Request Type")
        {
            Caption = 'Http Request Type';
            DataClassification = SystemMetadata;
        }
        // Description
        field(5; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        // OAuthType
        field(6; "OAuth Type"; Enum "YVS OAuth Type")
        {
            Caption = 'OAuth Type';
            DataClassification = SystemMetadata;
        }
        // OAuth URL
        field(7; "OAuth URL"; Text[250])
        {
            Caption = 'OAuth URL';
            DataClassification = SystemMetadata;
        }
        // OAuth Client ID
        field(8; "OAuth Client ID"; Text[250])
        {
            Caption = 'OAuth Client ID';
            DataClassification = SystemMetadata;
        }
        // OAuth Client Secret
        field(9; "OAuth Client Secret"; Text[250])
        {
            Caption = 'OAuth Client Secret';
            DataClassification = SystemMetadata;
            ExtendedDatatype = Masked;
        }
        // Access Token
        field(10; "Access Token"; Text[250])
        {
            Caption = 'Access Token';
            DataClassification = SystemMetadata;
            ExtendedDatatype = Masked;
        }
        // User Name
        field(12; "User Name"; Text[250])
        {
            Caption = 'User Name';
            DataClassification = SystemMetadata;
        }
        // User Password
        field(13; "User Password"; Text[250])
        {
            Caption = 'User Password';
            DataClassification = SystemMetadata;
            ExtendedDatatype = Masked;
        }
        // Active
        field(15; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = SystemMetadata;
        }
        // Time out
        field(16; "Time Out"; Integer)
        {
            Caption = 'Time out';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "API Key")
        {
            Clustered = true;
        }
    }

    procedure InitValues()
    begin
        "OAuth Type" := "OAuth Type"::"Client Credentials";
        "Time Out" := 1000;
    end;

    procedure IsActive(APIKey: Enum "YVS API Key"): Boolean
    var
        ExternalAppDef: Record "YVS External App Definition";
    begin
        ExternalAppDef.SetRange("API Key", APIKey);
        ExternalAppDef.SetRange("Active", true);
        exit(ExternalAppDef.FindFirst());
    end;
}