// TEMPLATE: Processing-only report — NO output, NO layout.
// Re-prefix {PREFIX} and re-ID from the ID Allocation Ledger (Report sub-range) before materializing.
//
// Use this scenario when the report object exists only to let the user set filters/options on a
// request page and then run an operation.
//
// HARD RULES for this scenario:
//   - ProcessingOnly = true
//   - NO rendering section
//   - NO layout file on disk
//   - NO DefaultRenderingLayout property
//   - Heavy logic lives in a Codeunit; the report only collects input and drives the loop.

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
                // Delegate the real work to a codeunit - keep the report thin.
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
                        ToolTip = 'Specifies the tax code to assign to the selected customers.';
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
