// TEMPLATE: Analytical report with an Excel layout (data for online consumption / analysis).
// Re-prefix {PREFIX} and re-ID from the ID Allocation Ledger (Report sub-range) before materializing.
//
// LAYOUT LIFECYCLE — do NOT skip:
//   1. Keep the rendering section below.
//   2. Build (Ctrl+Shift+B) -> the build generates VASSalesStatistics.xlsx.
//   3. Open the generated .xlsx in Excel; build PivotTables / charts / formulas over the data sheet; save.
//   4. Ctrl+F5 to render.
// NEVER hand-write the .xlsx.
//
// Layout name is deterministic: {PREFIX}{Name}.Excel  ->  "VASSalesStatistics.Excel"
//
// PERFORMANCE NOTE: for heavy multi-table joins, prefer a Query object as the source.
// Declare a global query variable, use Integer as the dataitem, and drive it from
// OnPreDataItem + OnAfterGetRecord.

report 50136 "VAS Sales Statistics"
{
    Caption = 'VAS Sales Statistics';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = "VASSalesStatistics.Excel";

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.", "Country/Region Code", "Date Filter";

            column(CustomerNo; "No.")
            {
                IncludeCaption = true;
            }
            column(CustomerName; Name)
            {
                IncludeCaption = true;
            }
            column(CountryRegionCode; "Country/Region Code")
            {
                IncludeCaption = true;
            }

            dataitem(CustLedgerEntry; "Cust. Ledger Entry")
            {
                DataItemLinkReference = Customer;
                DataItemLink = "Customer No." = field("No.");

                column(PostingDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(PostingYear; Date2DMY("Posting Date", 3))
                {
                    Caption = 'Posting Year';
                }
                column(PostingQuarter; QuarterText)
                {
                    Caption = 'Posting Quarter';
                }
                column(DocumentType; "Document Type")
                {
                    IncludeCaption = true;
                }
                column(SalesAmountLCY; "Sales (LCY)")
                {
                    IncludeCaption = true;
                }

                trigger OnAfterGetRecord()
                begin
                    // Shape the data here so the Excel layout stays simple.
                    QuarterText := StrSubstNo(QuarterLbl, Round((Date2DMY("Posting Date", 2) + 2) / 3, 1, '<'));
                end;
            }
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

                    field("VAS Include Credit Memos"; IncludeCreditMemos)
                    {
                        ApplicationArea = All;
                        Caption = 'Include Credit Memos';
                        ToolTip = 'Specifies whether credit memo entries are included in the statistics.';
                    }
                }
            }
        }
    }

    rendering
    {
        layout("VASSalesStatistics.Excel")
        {
            Type = Excel;
            LayoutFile = './src/Reports/VASSalesStatistics.xlsx';
            Caption = 'Sales Statistics (Excel)';
            Summary = 'Excel layout with pivot-ready sales data by customer and quarter.';
        }
    }

    var
        QuarterLbl: Label 'Q%1', Comment = '%1 = quarter number 1-4';
        QuarterText: Text[10];
        IncludeCreditMemos: Boolean;
}
