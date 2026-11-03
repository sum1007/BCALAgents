// TEMPLATE: Processing-only report — selects an API key and upserts its pending log records into BC.
// Generate ONE PER app; dispatch new API keys by adding a branch in ProcessSelectedApiKey().

report 50101 "YVS Generate Data"
{
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'YVS Generate Data';

    dataset
    {
        dataitem("YVS Integration History"; "YVS Integration History")
        {
            DataItemTableView = sorting("API Key", "Batch Key", "Transaction Date Time");
            RequestFilterFields = "API Key", "Batch Key", "Batch Status", "Transaction Date Time";

            trigger OnPreDataItem()
            begin
                if not IsNullGuid(SystemId) then
                    SetRange(SystemId, SystemId);

                SetRange("Batch Status", Enum::"YVS Integration Status"::Pending);
            end;

            trigger OnAfterGetRecord()
            var
                UpsertCustomerEngine: Codeunit "YVS Upsert Customer Engine";
                IntegrationEngine: Codeunit "YVS Integration Engine";
            begin
                case "API Key" of
                    "YVS API Key"::"Upsert Customer":
                        begin
                            ProcessedCount := UpsertCustomerEngine.GenerateData("API Key", "Batch Key");
                            if ProcessedCount > 0 then
                                IntegrationEngine.UpdateIntegrationHistoryStatus("API Key", "Batch Key", "Batch Status"::Success);
                        end;
                    else
                        Error(NoEngineErr, "API Key");
                end;
            end;

            trigger OnPostDataItem()
            begin
                Message(ProcessedMsg, ProcessedCount, "API Key")
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
            }
        }
    }

    var
        SystemId: Guid;
        ProcessedCount: Integer;
        NoEngineErr: Label 'There is no processing engine registered for API key %1.', Comment = '%1 = API key';
        ProcessedMsg: Label '%1 record(s) processed for API key %2.', Comment = '%1 = number of records, %2 = API key';

    procedure ParmRecordId(SystemIdPar: Guid)
    begin
        SystemId := SystemIdPar;
    end;
}
