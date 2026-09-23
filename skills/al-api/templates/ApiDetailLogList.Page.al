// TEMPLATE: Per-API detail list page.
// Generate ONE PER detail table, named "{PREFIX} {ApiName} Log List".
// Show the fixed log columns first, then every payload column, then the per-record result.

page 50121 "VAS Misa Invoice Log List"
{
    PageType = List;
    SourceTable = "VAS Misa Invoice Log";
    Caption = 'VAS Misa Invoice Log';
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
                // ---------- fixed log columns ----------
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the object id of the API.';
                }
                field("Batch Key"; Rec."Batch Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the GUID grouping all records of this run.';
                }
                field("Integration Key"; Rec."Integration Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the integration key for this record.';
                }

                // ---------- payload columns ----------
                field("VAS Invoice No."; Rec."VAS Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the invoice number in the payload.';
                }
                field("VAS Customer Code"; Rec."VAS Customer Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer code in the payload.';
                }
                field("VAS Customer Name"; Rec."VAS Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name in the payload.';
                }
                field("VAS Invoice Date"; Rec."VAS Invoice Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the invoice date in the payload.';
                }
                field("VAS Amount"; Rec."VAS Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount in the payload.';
                }
                field("VAS Currency"; Rec."VAS Currency")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency in the payload.';
                }
                field("VAS Is Vat"; Rec."VAS Is Vat")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether VAT applies.';
                }

                // ---------- per-record result ----------
                field("Integration Status"; Rec."Integration Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the result for this record.';
                }
                field("Integration Log"; Rec."Integration Log")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the integration log for this record, if any.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("VAS Show Log Header")
            {
                ApplicationArea = All;
                Caption = 'Show Log Header';
                ToolTip = 'Open the integration history entry for this batch key.';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    History: Record "VAS Integration History";
                begin
                    History.SetRange("Batch Key", Rec."Batch Key");
                    Page.Run(Page::"VAS Integration History List", History);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin

    end;
}
