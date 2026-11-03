// TEMPLATE: Level 1 header list page with drill-down to the per-API detail page.
// Generate ONCE per app. Re-prefix {PREFIX} and re-ID from the Ledger (Page sub-range).
//
// IMPORTANT: after generating a new detail table + list page, register a branch
// in OpenDetailPage() below (see references/logging-architecture.md).

page 50120 "YVS Integration History List"
{
    PageType = List;
    SourceTable = "YVS Integration History";
    Caption = 'YVS Integration History';
    ApplicationArea = All;
    UsageCategory = History;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
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
                field("Batch Key"; Rec."Batch Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the GUID grouping all records of this run.';
                }
                field(Direction; Rec.Direction)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the call was inbound or outbound.';
                }
                field("Batch Status"; Rec."Batch Status")
                {
                    ApplicationArea = All;
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
            action("YVS View Detail")
            {
                ApplicationArea = All;
                Caption = 'View Detail';
                ToolTip = 'Open the per-API detail log filtered by this batch key.';
                //Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    OpenDetailPage();
                end;
            }
            action("YVS Generate Data")
            {
                ApplicationArea = All;
                Caption = 'Generate Data';
                ToolTip = 'Generate data for the selected API key and batch.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    GenerateDataReport: Report "YVS Generate Data";
                begin
                    GenerateDataReport.ParmRecordId(Rec.SystemId);
                    GenerateDataReport.Run();
                end;
            }
            action("YVS Reset Data")
            {
                ApplicationArea = All;
                Caption = 'Reset Data';
                ToolTip = 'Reset data for the selected API key and batch.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ResetDataReport: Report "YVS Reset Data";
                begin
                    ResetDataReport.ParmRecordId(Rec.SystemId);
                    ResetDataReport.Run();
                end;
            }
            action("YVS Cancel Data")
            {
                ApplicationArea = All;
                Caption = 'Cancel Data';
                ToolTip = 'Cancel data for the selected API key and batch.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    CancelDataReport: Report "YVS Cancel Data";
                begin
                    CancelDataReport.ParmRecordId(Rec.SystemId);
                    CancelDataReport.Run();
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
        CustLog: Record "YVS Upsert Customer Log";
        NoDetailPageMsg: Label 'No detail page is registered for API %1.', Comment = '%1 = API name';
    begin
        case Rec."API Key" of
            Rec."API Key"::"Upsert Customer":
                begin
                    CustLog.SetRange("API Key", Rec."API Key");
                    CustLog.SetRange("Batch Key", Rec."Batch Key");
                    Page.Run(Page::"YVS Upsert Customer Log List", CustLog);
                end;
            else
                Message(NoDetailPageMsg, Rec."API Key"::"Upsert Customer");
        end;
    end;
}
