// TEMPLATE: List page for the Upsert Customer detail log.
// Re-prefix {PREFIX} and re-ID from the project ledger before materializing.

page 50124 "YVS Sales Invoice Log List"
{
    PageType = List;
    SourceTable = "YVS Sync Sales Invoice Log";
    Caption = 'YVS Sync Sales Invoice Log';
    ApplicationArea = All;
    UsageCategory = History;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the object id of the inbound codeunit.';
                }
                field("Batch Key"; Rec."Batch Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the logging batch key generated for this request.';
                }
                field("Integration Key"; Rec."Integration Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the integration key from the request item.';
                }
                field("Integration Status"; Rec."Integration Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the batch key supplied by the external system.';
                }
                field("Integration Log"; Rec."Integration Log")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the processing message for the request item.';
                }
                field("YVS Document No"; Rec."YVS Document No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document number supplied by the external system.';
                }
                field("YVS Customer No"; Rec."YVS Customer No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number supplied by the external system.';
                }
                field("YVS Customer Name"; Rec."YVS Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name supplied by the external system.';
                }
                field("YVS Legal Entity Id"; Rec."YVS Legal Entity Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the legal entity identifier from the request.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("YVS View Integration History")
            {
                ApplicationArea = All;
                Caption = 'View Integration History';
                ToolTip = 'Open the integration history filtered by this batch key.';
                //Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    OpenIntegrationHistory();
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

    local procedure OpenIntegrationHistory()
    var
        IntegrationHistory: Record "YVS Integration History";
    begin
        IntegrationHistory.SetRange("API Key", Rec."API Key");
        IntegrationHistory.SetRange("Batch Key", Rec."Batch Key");
        Page.Run(Page::"YVS Integration History List", IntegrationHistory);
    end;
}
