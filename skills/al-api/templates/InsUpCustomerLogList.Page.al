// TEMPLATE: List page for the InsUpCustomer detail log.
// Re-prefix {PREFIX} and re-ID from the project ledger before materializing.

page 50122 "VAS InsUpCustomer Log List"
{
    PageType = List;
    SourceTable = "VAS InsUpCustomer Log";
    Caption = 'VAS InsUpCustomer Log';
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
                field("VAS Request Batch Key"; Rec."VAS Request Batch Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the batch key supplied by the external system.';
                }
                field("VAS Line Number"; Rec."VAS Line Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line number supplied by the external system.';
                }
                field("VAS Legal Entity Id"; Rec."VAS Legal Entity Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the legal entity supplied by the external system.';
                }
                field("VAS Customer Id"; Rec."VAS Customer Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer identifier from the request.';
                }
                field("VAS Customer Name"; Rec."VAS Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name from the request.';
                }
                field("Integration Status"; Rec."Integration Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the processing status of the request item.';
                }
                field("Integration Log"; Rec."Integration Log")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the processing message for the request item.';
                }
            }
        }
    }
}
