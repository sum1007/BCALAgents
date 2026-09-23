// TEMPLATE: Level 1 header list page with drill-down to the per-API detail page.
// Generate ONCE per app. Re-prefix {PREFIX} and re-ID from the Ledger (Page sub-range).
//
// IMPORTANT: after generating a new detail table + list page, register a branch
// in OpenDetailPage() below (see references/logging-architecture.md).

page 50120 "VAS Integration History List"
{
    PageType = List;
    SourceTable = "VAS Integration History";
    Caption = 'VAS Integration History';
    ApplicationArea = All;
    UsageCategory = History;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTableView = sorting("Entry No.") order(descending);

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
                field("API Name"; Rec."API Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the API object name.';
                }
                field(Direction; Rec.Direction)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the call was inbound or outbound.';
                }
                field("Batch Key"; Rec."Batch Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the GUID grouping all records of this run.';
                }
                field("Batch Status"; Rec."Batch Status")
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Specifies the result status of the call.';
                }
                field("Record Count"; Rec."Record Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of detail records logged.';
                }
                field("Transaction Date Time"; Rec."Transaction Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the transaction occurred.';
                }
                field("Batch Log"; Rec."Batch Log")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the batch log text, if any.';
                }
                field("Request Json"; Rec.GetRequestJson())
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the stored request JSON payload.';
                }
                field("Response Json"; Rec.GetResponseJson())
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the stored response JSON payload.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("VAS View Detail")
            {
                ApplicationArea = All;
                Caption = 'View Detail';
                ToolTip = 'Open the per-API detail log filtered by this batch key.';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    OpenDetailPage();
                end;
            }
            action("VAS View Request JSON")
            {
                ApplicationArea = All;
                Caption = 'View Request JSON';
                ToolTip = 'Show the stored request payload.';
                Image = Export;

                trigger OnAction()
                begin
                    Message(Rec.GetRequestJson());
                end;
            }
            action("VAS View Response JSON")
            {
                ApplicationArea = All;
                Caption = 'View Response JSON';
                ToolTip = 'Show the stored response payload.';
                Image = Import;

                trigger OnAction()
                begin
                    Message(Rec.GetResponseJson());
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
    end;

    /// Routes to the correct per-API detail page based on Detail Table No.
    /// Add one branch per generated detail table.
    local procedure OpenDetailPage()
    var
        CustLog: Record "VAS Api Customer Log";
        NoDetailPageMsg: Label 'No detail page is registered for API %1.', Comment = '%1 = table object id';
    begin
        case Rec."API Key" of
            Page::"VAS Api Customers":
                begin
                    CustLog.SetRange("API Key", Rec."API Key");
                    CustLog.SetRange("Batch Key", Rec."Batch Key");
                    Page.Run(Page::"VAS Api Customer Log List", CustLog);
                end;
            else
                Message(NoDetailPageMsg, Rec."API Name");
        end;
    end;
}
