codeunit 50135 "YVS Upsert Customer API"
{
    procedure UpSertCustomer(payload: Text) JsonResponseText: Text
    var
        TempJsonRequestBuffer: Record "JSON Buffer" temporary;
        DataJsonBuffer: Record "JSON Buffer" temporary;
        UpSertCustomerLog: Record "YVS UpSert Customer Log";
        YVSIntegrationEngine: Codeunit "YVS Integration Engine";
        RequestJsonObject: JsonObject;
        ResponseJsonObject: JsonObject;
        ResponseDataJsonObject: JsonObject;
        ResponseDataJsonArray: JsonArray;
        JsonToken: JsonToken;
        IntegrationLog: Text;
        TempValue: Text;
        LegalEntityId: Text;
        BatchKey: Guid;
        IntegrationKey: Guid;
        ICreated: Integer;
        ICreatedLineNotSync: Integer;
        LineNotSyncMsg: Label 'Some lines failed to sync.';
        FieldMissingMsg: Label '%1 is missing in the request.';
    begin
        payload := '{"batchkey":"{70D52FF8-BC3A-4978-BEEC-A429BFB02B2B}","data":[{"integrationkey":"{70D52FF8-BC3A-4978-BEEC-A429BFB02B2B}","customerid":"TEST01","customername":"test name"}],"legalentityid":"kfm"}';
        ICreated := 0;
        ICreatedLineNotSync := 0;
        RequestJsonObject.ReadFrom(payload);
        TempJsonRequestBuffer.ReadFromText(payload);
        if RequestJsonObject.Get('legalentityid', JsonToken) then begin
            if not JsonToken.AsValue().IsNull() then
                LegalEntityId := JsonToken.AsValue().AsText();
        end;
        TempJsonRequestBuffer.GetPropertyValue(LegalEntityId, 'legalentityid');
        if LegalEntityId <> '' then begin
            UpSertCustomerLog.ChangeCompany(LegalEntityId);
            TempJsonRequestBuffer.GetPropertyValue(TempValue, 'batchkey');
            Evaluate(BatchKey, TempValue);
            if IsNullGuid(BatchKey) then
                BatchKey := CreateGuid();
            if TempJsonRequestBuffer.FindArray(DataJsonBuffer, 'data') then begin
                repeat
                    DataJsonBuffer.GetPropertyValue(TempValue, 'customerid');
                    UpSertCustomerLog."YVS Customer Id" := TempValue;
                    DataJsonBuffer.GetPropertyValue(TempValue, 'customername');
                    UpSertCustomerLog."YVS Customer Name" := TempValue;
                    DataJsonBuffer.GetPropertyValue(TempValue, 'integrationkey');
                    Evaluate(IntegrationKey, TempValue);
                    if IsNullGuid(IntegrationKey) then
                        IntegrationKey := CreateGuid();
                    UpSertCustomerLog."Integration Key" := IntegrationKey;
                    UpSertCustomerLog."YVS Legal Entity Id" := LegalEntityId;
                    UpSertCustomerLog."Batch Key" := BatchKey;
                    UpSertCustomerLog."API Key" := UpSertCustomerLog."API Key"::"Upsert Customer";
                    UpSertCustomerLog.ValidateData();
                    UpSertCustomerLog.Insert();
                    ICreated += 1;
                    if UpSertCustomerLog."Integration Status" = UpSertCustomerLog."Integration Status"::"Failed" then begin
                        ICreatedLineNotSync += 1;
                        ResponseDataJsonObject.Add('customerid', UpSertCustomerLog."YVS Customer Id");
                        ResponseDataJsonObject.Add('customername', UpSertCustomerLog."YVS Customer Name");
                        ResponseDataJsonObject.Add('integrationkey', UpSertCustomerLog."Integration Key");
                        ResponseDataJsonObject.Add('integrationstatus', Format(UpSertCustomerLog."Integration Status"));
                        ResponseDataJsonObject.Add('integrationlog', UpSertCustomerLog."Integration Log");
                        ResponseDataJsonArray.Add(ResponseDataJsonObject);
                    end
                until DataJsonBuffer.Next() = 0;
            end;
        end else begin
            IntegrationLog := StrSubstNo(FieldMissingMsg, 'LegalEntityId');
        end;
        if ICreatedLineNotSync > 0 then
            IntegrationLog := LineNotSyncMsg;
        ResponseJsonObject.Add('legalentityid', LegalEntityId);
        ResponseJsonObject.Add('batchkey', BatchKey);
        if IntegrationLog <> '' then
            ResponseJsonObject.Add('batchstatus', Format(Enum::"YVS Integration Status"::Failed))
        else
            ResponseJsonObject.Add('batchstatus', Format(Enum::"YVS Integration Status"::Success));
        ResponseJsonObject.Add('batchlog', IntegrationLog);
        ResponseJsonObject.Add('data', ResponseDataJsonArray);
        ResponseJsonObject.WriteTo(JsonResponseText);

        YVSIntegrationEngine.UpdateIntegrationHistory(
            UpSertCustomerLog."API Key"::"Upsert Customer",
            BatchKey,
            CurrentDateTime(),
            payload,
            JsonResponseText,
            IntegrationLog <> '' ? Enum::"YVS Integration Status"::Failed : Enum::"YVS Integration Status"::Pending,
            IntegrationLog,
            ICreated);
    end;
}