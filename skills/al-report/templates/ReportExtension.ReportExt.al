// TEMPLATE: ReportExtension (uses ReportExtension ID sub-range; requires manual selection in Report Layout Selection).
reportextension 50139 "VAS Sales Invoice Ext" extends "Standard Sales - Invoice"
{
    dataset
    {
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
            column(VASShowContractInfo; VASShowContractInfo)
            {
                Caption = 'Show Contract Info';
            }
        }

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
                column(VASContractStartDate; Format("Start Date"))
                {
                    Caption = 'Contract Start Date';
                }

                trigger OnPreDataItem()
                begin
                    if not VASShowContractInfo then
                        CurrReport.Break();
                end;
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
        layout("VASSalesInvoice.Word")
        {
            Type = Word;
            LayoutFile = './src/Reports/VASSalesInvoice.docx';
            Caption = 'Sales Invoice - VAS Localization (Word)';
            Summary = 'Localized invoice layout including tax code and contract details.';
        }
    }

    labels
    {
        VASContractSectionLbl = 'Contract Information';
    }

    var
        VASShowContractInfo: Boolean;
}
