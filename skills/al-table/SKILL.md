---
name: al-table
description: Creates and edits Business Central Table and TableExtension objects in AL. Use when adding a new table, adding fields to a standard table such as Customer or Item, or defining keys, DataClassification, and the AppSource affix on fields.
license: Proprietary
metadata:
  author: Votiva
  version: "1.0.0"
---

## SKILL: al-table — Table & TableExtension (Dynamics 365 Business Central, AL)

> Owned by **BC AL Generation Assistant** (@bc-basic-creation).
> Resolve `{PREFIX}`, `{ObjectIdRange}` from instructions/model/app-analysis.instructions.md §Quick Reference. NEVER guess. NEVER copy `YVS` from examples.

### When to use
- New master/document/setup/ledger table → **Table**.
- Adding fields to a base app table (Customer, Item, Sales Header, ...) → **TableExtension** (base app is never editable).

### Decision
| Need | Object | ID from |
|---|---|---|
| Brand-new entity | `table` | ID range 50100–50109 |
| Extra fields on a standard table | `tableextension` | ID range 50100–50109 |

### Rules (HARD)
- Object name: `{PREFIX} {Name}` (e.g. "VAS Delivery Note Header"). File: `src/Tables/{PREFIX}{Name}.Table.al`.
- Extension name: `"{PREFIX} {StdTable} Ext"` extends the base table. File: `src/TableExtensions/{PREFIX}{StdTable}.TableExt.al`.
- EVERY field carries the `{PREFIX}` affix AND a `DataClassification` (default `CustomerContent`).
- Field numbers: new table use 1..n; **tableextension fields must use the licensed field-ID range** (e.g. 50100+). Never reuse base field IDs.
- Add at least one key; add `Caption`/`ToolTip` where surfaced on pages.
- No breaking changes on shipped tables — obsolete via `ObsoleteState = Pending` → `Removed` next major.

### Steps
1. Resolve `{PREFIX}` + next free object ID (ID Allocation Ledger, Table sub-range).
2. Decide Table vs TableExtension.
3. Define fields (prefix + DataClassification + Caption), keys, and any `FlowField`/`CalcFormula`.
4. Add table triggers only if needed (`OnInsert`, `OnModify`, `OnValidate` per field).
5. Update the ID Allocation Ledger; emit the field to the Handoff Contract.

### Template — Table
```al
table 50100 "VAS Delivery Note Header"
{
    Caption = 'VAS Delivery Note Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "VAS Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(3; "VAS Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}
```

### Template — TableExtension
```al
tableextension 50100 "VAS Customer Ext" extends Customer
{
    fields
    {
        field(50100; "VAS Tax Code"; Code[20])
        {
            Caption = 'Tax Code';
            DataClassification = CustomerContent;
        }
    }
}
```

### Verify before handoff
- File exists; header type + ID + `{PREFIX}` name match. Every field prefixed + has DataClassification. No scaffold `MyField`. Keys present.
