// TEMPLATE: Document report with Word layout (complete dataset: company info, filters, totals, and labels block).
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
            PrintOnlyIfDetail = true;

            column(CompanyName; CompanyInfo.Name) { }
            column(CompanyAddress; CompanyInfo.Address) { }
            column(CompanyVATRegNo; CompanyInfo."VAT Registration No.") { }
            column(CustomerFilter; CustomerFilterText) { }
            column(CustomerNo; "No.")
            {
                IncludeCaption = true;
            }
            column(CustomerName; Name)
            {
                IncludeCaption = true;
            }
            column(TotalAmountFormatted; Format(TotalAmountLCY, 0, '<Precision,2:2><Standard Format,0>')) { }

            dataitem(CustLedgerEntry; "Cust. Ledger Entry")
            {
                DataItemLinkReference = Customer;
                DataItemLink = "Customer No." = field("No."), "Posting Date" = field("Date Filter");
                DataItemTableView = sorting("Customer No.", "Posting Date");

                column(PostingDate; Format("Posting Date"))
                {
                    Caption = 'Posting Date';
                }
                column(DocumentNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(EntryDescription; Description)
                {
                    IncludeCaption = true;
                }
                column(AmountFormatted; Format("Amount (LCY)", 0, '<Precision,2:2><Standard Format,0>'))
                {
                    Caption = 'Amount (LCY)';
                }

                trigger OnPreDataItem()
                begin
                    if not ShowDetails then
                        CurrReport.Break();
                end;

                trigger OnAfterGetRecord()
                begin
                    TotalAmountLCY += "Amount (LCY)";
                end;
            }

            trigger OnAfterGetRecord()
            begin
                TotalAmountLCY := 0;
                if not ShowDetails then begin
                    CalcFields("Net Change (LCY)");
                    TotalAmountLCY := "Net Change (LCY)";
                end;
            end;
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

                    field("VAS Show Details"; ShowDetails)
                    {
                        ApplicationArea = All;
                        Caption = 'Show Details';
                        ToolTip = 'Specifies whether individual customer ledger entries are listed on the statement.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if not Initialized then begin
                ShowDetails := true;
                Initialized := true;
            end;
        end;
    }

    rendering
    {
        layout("VASCustomerStatement.Word")
        {
            Type = Word;
            LayoutFile = './src/Reports/VASCustomerStatement.docx';
            Caption = 'Customer Statement (Word)';
            Summary = 'Standard A4 Word layout with company header, ledger entries, and total row.';
        }
    }

    labels
    {
        StatementTitleLbl = 'CUSTOMER STATEMENT';
        PageCaptionLbl = 'Page';
        TotalCaptionLbl = 'Total (LCY)';
        PreparedByLbl = 'Prepared By';
        ApprovedByLbl = 'Approved By';
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CustomerFilterText := Customer.GetFilters();
    end;

    var
        CompanyInfo: Record "Company Information";
        CustomerFilterText: Text;
        TotalAmountLCY: Decimal;
        ShowDetails: Boolean;
        Initialized: Boolean;
}
