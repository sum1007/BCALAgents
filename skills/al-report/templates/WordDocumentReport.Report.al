// TEMPLATE: Document report with a Word layout (the default choice for printed/PDF output).
// Re-prefix {PREFIX} and re-ID from the ID Allocation Ledger (Report sub-range) before materializing.
//
// LAYOUT LIFECYCLE — do NOT skip:
//   1. Keep the rendering section below.
//   2. Build (Ctrl+Shift+B) -> the build generates VASCustomerStatement.docx with the Custom XML part.
//   3. Open the generated .docx in Word, insert a table, drag the fields in, save.
//   4. Ctrl+F5 to render.
// NEVER hand-write the .docx. NEVER emit <Report>, <DataSets>, <Fields>, or <DataField>.
//
// Layout name is deterministic: {PREFIX}{Name}.Word  ->  "VASCustomerStatement.Word"

report 50135 "VAS Customer Statement"
{
    Caption = 'VAS Customer Statement';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = "VASCustomerStatement.Word";

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.", "Date Filter";

            // Friendly, self-describing names - the layout author picks these in the Word data picker.
            column(CustomerNo; "No.")
            {
                IncludeCaption = true;
            }
            column(CustomerName; Name)
            {
                IncludeCaption = true;
            }

            dataitem(CustLedgerEntry; "Cust. Ledger Entry")
            {
                // Set BOTH properties on the CHILD data item.
                DataItemLinkReference = Customer;
                DataItemLink = "Customer No." = field("No.");

                column(PostingDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(DocumentNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(EntryDescription; Description)
                {
                    IncludeCaption = true;
                }
                // Format in the DATASET, not in the layout.
                column(AmountFormatted; Format(Amount, 0, '<Precision,2:2><Standard Format,0>'))
                {
                    Caption = 'Amount';
                }
            }

            trigger OnPreDataItem()
            begin
                if ShowDetails then
                    CurrReport.Break();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field("VAS Show Details"; ShowDetails)
                    {
                        ApplicationArea = All;
                        Caption = 'Show Details';
                        ToolTip = 'Specifies whether individual ledger entries are included in the statement.';
                    }
                }
            }
        }
    }

    rendering
    {
        layout("VASCustomerStatement.Word")
        {
            Type = Word;
            LayoutFile = './src/Reports/VASCustomerStatement.docx';
            Caption = 'Customer Statement (Word)';
            Summary = 'Default Word layout for the customer statement.';
        }
    }

    var
        StatementTitleLbl: Label 'Customer Statement';
        PageLbl: Label 'Page';
        ShowDetails: Boolean;
}
