// TEMPLATE: ReportExtension — add dataitems, columns, request-page fields, or a layout to a standard report.
// Re-prefix {PREFIX} and re-ID from the ID Allocation Ledger (ReportExtension sub-range).
//
// HARD: the ReportExtension ID comes from the ReportExtension sub-range, NOT the Report sub-range.
//       A Report and a ReportExtension must never share an object ID.
//
// CRITICAL POST-DEPLOY STEP — surface this to the user in the handoff:
//   A layout shipped inside a report extension is NOT applied automatically.
//   The user must open the "Report Layout Selection" page in Business Central and pick the new
//   layout from the "Custom Layout Description" dropdown for this report.

reportextension 50138 "VAS Sales Invoice Ext" extends "Standard Sales - Invoice"
{
    dataset
    {
        // Add columns to an existing data item by name.
        add(Header)
        {
            column(VASTaxCode; "Sales Invoice Header"."VAS Tax Code")
            {
                IncludeCaption = true;
            }
            column(VASContractNo; "Sales Invoice Header"."VAS Contract No.")
            {
                IncludeCaption = true;
            }
        }

        // Add a new child data item. Set BOTH link properties on the child.
        addlast(Header)
        {
            dataitem(VASContract; "VAS Contract Header")
            {
                DataItemLinkReference = Header;
                DataItemLink = "No." = field("VAS Contract No.");

                column(VASContractDescription; Description)
                {
                    IncludeCaption = true;
                }
                column(VASContractStartDate; "Start Date")
                {
                    IncludeCaption = true;
                }
            }
        }
    }

    requestpage
    {
        layout
        {
            addlast(Content)
            {
                field("VAS Show Contract Info"; VASShowContractInfo)
                {
                    ApplicationArea = All;
                    Caption = 'Show Contract Info';
                    ToolTip = 'Specifies whether contract details are printed on the invoice.';
                }
            }
        }
    }

    rendering
    {
        // Optional: ship an alternative layout for the standard report.
        // Build (Ctrl+Shift+B) generates the .docx - never hand-write it.
        layout("VASSalesInvoice.Word")
        {
            Type = Word;
            LayoutFile = './src/Reports/VASSalesInvoice.docx';
            Caption = 'Sales Invoice - VAS Localization (Word)';
            Summary = 'Localized invoice layout including tax code and contract details.';
        }
    }

    var
        VASShowContractInfo: Boolean;
}
