// TEMPLATE: Inbound processing engine — upserts pending detail log rows into the BC Customer table.
// Generate ONE PER inbound API. Re-prefix {PREFIX} and re-ID from the Ledger.

codeunit 50134 "YVS Upsert Customer Engine"
{
    /// <summary>
    /// Scans all pending "YVS Upsert Customer Log" rows and upserts each into the Customer table.
    /// </summary>
    /// <returns>The number of rows successfully processed.</returns>
    procedure GenerateData(APIKey: Enum "YVS API Key"; BatchKey: Guid): Integer
    var
        DetailLog: Record "YVS Upsert Customer Log";
        ProcessedCount: Integer;
    begin
        DetailLog.SetCurrentKey("API Key", "Batch Key");
        DetailLog.SetRange("API Key", APIKey);
        DetailLog.SetRange("Batch Key", BatchKey);
        if not DetailLog.FindSet(true) then
            exit(0);

        repeat
            if UpsertCustomer(DetailLog) then begin
                DetailLog."Integration Status" := DetailLog."Integration Status"::"Success";
                DetailLog."Integration Log" := '';
                ProcessedCount += 1;
            end else begin
                DetailLog."Integration Status" := DetailLog."Integration Status"::"Failed";
                DetailLog."Integration Log" := CopyStr(GetLastErrorText(), 1, MaxStrLen(DetailLog."Integration Log"));
            end;
            DetailLog.Modify(true);
        until DetailLog.Next() = 0;

        exit(ProcessedCount);
    end;

    procedure CancelData(APIKey: Enum "YVS API Key"; BatchKey: Guid): Integer
    var
        DetailLog: Record "YVS Upsert Customer Log";
    begin
        DetailLog.SetCurrentKey("API Key", "Batch Key");
        DetailLog.SetRange("API Key", APIKey);
        DetailLog.SetRange("Batch Key", BatchKey);
        DetailLog.ModifyAll("Integration Status", DetailLog."Integration Status"::Cancelled);

        exit(DetailLog.Count());
    end;

    procedure ResetData(APIKey: Enum "YVS API Key"; BatchKey: Guid): Integer
    var
        DetailLog: Record "YVS Upsert Customer Log";
    begin
        DetailLog.SetCurrentKey("API Key", "Batch Key");
        DetailLog.SetRange("API Key", APIKey);
        DetailLog.SetRange("Batch Key", BatchKey);
        DetailLog.ModifyAll("Integration Status", DetailLog."Integration Status"::Pending);

        exit(DetailLog.Count());
    end;

    [TryFunction]
    local procedure UpsertCustomer(DetailLog: Record "YVS Upsert Customer Log")
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(DetailLog."YVS Customer Id") then begin
            Customer.Init();
            Customer."No." := DetailLog."YVS Customer Id";
            Customer.Insert(true);
        end;
        Customer.Name := DetailLog."YVS Customer Name";
        Customer.Modify(true);
    end;
}
