---
name: al-report
description: Creates Business Central Report and ReportExtension objects in AL. Use when building a printout or analysis report, choosing a Word or Excel layout, defining the dataset and request page, or extending a standard report.
license: Proprietary
metadata:
  author: Votiva
  version: "1.0.0"
---

## SKILL: al-report — Report & ReportExtension (Dynamics 365 Business Central, AL)

> Owned by **BC AL Generation Assistant** (@bc-basic-creation) / **BC Resource Reuse Assistant** for reporting templates.
> Resolve `{PREFIX}`, `{ObjectIdRange}` from app-analysis §Quick Reference. NEVER guess. NEVER copy `YVS`.

### When to use
- New printout / document / analysis output → **Report**.
- Add a dataitem/column/request-page field to a standard report → **ReportExtension**.

### Layout choice (Rule §15)
| Need | Layout |
|---|---|
| Business document / letter | **Word (.docx)** — preferred |
| Data dump / analytics | **Excel** |
| Pixel-precise legacy | RDLC (only when required) |
- Layout file lives beside the report `.al`: `src/Reports/{PREFIX}{Name}.Report.al` + `{PREFIX}{Name}.docx`.

### Rules (HARD)
- Object name `{PREFIX} {Name}`. Every column/label with `Caption`. Request-page fields prefixed + `ApplicationArea`.
- Set `DefaultRenderingLayout` and declare `rendering { layout(...) }`.
- Heavy logic goes to a Codeunit; the report only shapes data + triggers.
- `UsageCategory` + `ApplicationArea` if it should appear in search.

### Steps
1. Resolve `{PREFIX}` + next free ID (Report sub-range 50135–50139).
2. Define `dataset` (dataitems + columns), `requestpage` (filters/options), and `rendering`.
3. Create the matching layout file (Word/Excel) beside the .al.
4. Update ID Ledger; set `translationFileTouched` if captions added; emit to Handoff Contract.

### Template — Report (Word layout)
```al
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
            column(Name; Name) { }
            column(No; "No.") { }

            dataitem(CustLedgerEntry; "Cust. Ledger Entry")
            {
                DataItemLink = "Customer No." = field("No.");
                column(DocumentNo; "Document No.") { }
                column(Amount; Amount) { }
            }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                field("VAS Show Details"; ShowDetails)
                {
                    ApplicationArea = All;
                    Caption = 'Show Details';
                    ToolTip = 'Include individual ledger entries.';
                }
            }
        }
    }

    rendering
    {
        layout("VASCustomerStatement.Word")
        {
            Type = Word;
            LayoutFile = './src/Reports/VASCustomerStatement.docx';
            Caption = 'Customer Statement (Word)';
        }
    }

    var
        ShowDetails: Boolean;
}
```

### Template — ReportExtension
```al
reportextension 50135 "VAS Sales Invoice Ext" extends "Standard Sales - Invoice"
{
    dataset
    {
        add(Header)
        {
            column(VASTaxCode; "Sales Invoice Header"."VAS Tax Code") { }
        }
    }
}
```

### Verify before handoff
- Prefixed name + ID in range. Layout file present beside .al and referenced. Columns/request fields captioned + prefixed. No scaffold names.
