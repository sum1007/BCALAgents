pageextension 50100 "YVS Business Manager Role Ext" extends "Business Manager Role Center" //9022
{
    actions
    {
        addfirst(sections)
        {
            group(YVSIMM)
            {
                Caption = 'Integration management';
                Image = Setup;
                group(YVSPeriodicTask)
                {
                    Caption = 'Periodic Task';

                    action(YVSGenerateData)
                    {
                        ApplicationArea = All;
                        Caption = 'Generate Data';
                        RunObject = report "YVS Generate Data";
                    }
                }
                group(YVSInquiriesAndReports)
                {
                    Caption = 'Inquiries and Reports';

                    action(YVSIntegrationHistory)
                    {
                        ApplicationArea = All;
                        Caption = 'Integration History';
                        RunObject = page "YVS Integration History List";
                    }
                    action(YVSUpSertCustomerLog)
                    {
                        ApplicationArea = All;
                        Caption = 'Upsert Customer Log';
                        RunObject = page "YVS Upsert Customer Log List";
                    }
                    action(YVSSyncSalesInvoiceLog)
                    {
                        ApplicationArea = All;
                        Caption = 'Sync Sales Invoice Log';
                        RunObject = page "YVS Sales Invoice Log List";
                    }
                }
                group(YVSSetup)
                {
                    Caption = 'Setup';

                    action(YVSExternalApplicationDefinition)
                    {
                        ApplicationArea = All;
                        Caption = 'External Application Definition';
                        RunObject = page "YVS Ext. App Definition List";
                    }
                }
            }
        }
    }
}