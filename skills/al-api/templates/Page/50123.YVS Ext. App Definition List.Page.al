page 50123 "YVS Ext. App Definition List"
{
    PageType = List;
    SourceTable = "YVS External App Definition";
    Caption = 'YVS External App Definition';
    ApplicationArea = All;
    UsageCategory = History;
    CardPageId = "YVS Ext. App Definition Card";
    SourceTableView = sorting("API Key") order(descending);

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the object id of the API that produced this entry.';
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the external application.';
                }
                field("OAuth Type"; Rec."OAuth Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the OAuth type used by the external application.';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the external application is active.';
                }
                field("Time Out"; Rec."Time Out")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Time Out value of the external application.';
                }
            }
        }
    }

}