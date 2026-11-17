// TEMPLATE: Processing-only report (ProcessingOnly = true, no rendering section, no layout file).
report 50137 "VAS Update Customer Tax Codes"
{
    Caption = 'VAS Update Customer Tax Codes';
    ApplicationArea = All;
    UsageCategory = Tasks;
    ProcessingOnly = true;
    UseRequestPage = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.", "Country/Region Code";

            trigger OnPreDataItem()
            begin
                ProcessedCount := 0;
            end;

            trigger OnAfterGetRecord()
            begin
                if TaxMgt.UpdateTaxCode(Customer, NewTaxCode, OverwriteExisting) then
                    ProcessedCount += 1;
            end;

            trigger OnPostDataItem()
            begin
                if ProcessedCount = 0 then
                    Message(NothingProcessedMsg)
                else
                    Message(ProcessedMsg, ProcessedCount);
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

                    field("VAS New Tax Code"; NewTaxCode)
                    {
                        ApplicationArea = All;
                        Caption = 'New Tax Code';
                        ToolTip = 'Specifies the tax code to assign to the filtered customers.';
                    }
                    field("VAS Overwrite Existing"; OverwriteExisting)
                    {
                        ApplicationArea = All;
                        Caption = 'Overwrite Existing';
                        ToolTip = 'Specifies whether customers that already have a tax code are updated.';
                    }
                }
            }
        }

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction in [Action::OK, Action::LookupOK] then
                if NewTaxCode = '' then
                    Error(TaxCodeRequiredErr);
            exit(true);
        end;
    }

    var
        TaxMgt: Codeunit "VAS Customer Tax Mgt.";
        NewTaxCode: Code[20];
        OverwriteExisting: Boolean;
        ProcessedCount: Integer;
        ProcessedMsg: Label '%1 customer(s) were updated.', Comment = '%1 = number of customers processed';
        NothingProcessedMsg: Label 'No customers matched the selected filters.';
        TaxCodeRequiredErr: Label 'You must specify a new tax code before running this task.';
}
