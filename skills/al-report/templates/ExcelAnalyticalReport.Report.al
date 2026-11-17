// TEMPLATE: Analytical report with Excel layout (raw Decimal/Date columns for PivotTables + wired options).
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
                DataItemLink = "Customer No." = field("No."), "Posting Date" = field("Date Filter");

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
                column(DocumentNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(SalesAmountLCY; "Sales (LCY)")
                {
                    IncludeCaption = true;
                }

                trigger OnPreDataItem()
                begin
                    if not IncludeCreditMemos then
                        SetFilter("Document Type", '<>%1', "Document Type"::"Credit Memo");
                end;

                trigger OnAfterGetRecord()
                begin
                    QuarterText := StrSubstNo(QuarterLbl, Round((Date2DMY("Posting Date", 2) + 2) / 3, 1, '<'));
                end;
            }
        }
    }

    requestpage
    {
        SaveValues = true;

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
                        ToolTip = 'Specifies whether credit memo ledger entries are included in the exported dataset.';
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
            Summary = 'Pivot-ready sales dataset by customer, year, and quarter.';
        }
    }

    labels
    {
        ReportTitleLbl = 'Sales Statistics Analysis';
    }

    var
        QuarterLbl: Label 'Q%1', Comment = '%1 = quarter number 1-4';
        QuarterText: Text[10];
        IncludeCreditMemos: Boolean;
}
