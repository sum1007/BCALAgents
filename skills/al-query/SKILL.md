---
name: al-query
description: Builds Business Central Query objects in AL. Use when creating a read-only joined or aggregated dataset for charts, OData, or code, with dataitem links, Sum or Count methods, and OrderBy.
license: Proprietary
metadata:
  author: Votiva
  version: "1.0.0"
---

## SKILL: al-query — Query (Dynamics 365 Business Central, AL)

> Owned by **BC AL Generation Assistant** (@bc-basic-creation). API queries → see al-api.
> Resolve `{PREFIX}`, `{ObjectIdRange}` from app-analysis §Quick Reference. NEVER guess. NEVER copy `YVS`.

### When to use
- Read-only joined/aggregated dataset for charts, OData, or `QueryType = Normal` consumption in code.
- For an OData/API-exposed query → `QueryType = API` (see al-api for metadata rules).

### Rules (HARD)
- Object name `{PREFIX} {Name}`. File `src/Queries/{PREFIX}{Name}.Query.al`.
- Columns exposed via OData carry the `{PREFIX}` affix + `Caption`.
- Use `dataitem` links for joins; `method = Sum/Count/Average` on columns for aggregation; `OrderBy` for sorting.
- Queries are read-only — no writes, no heavy logic. For processing, read the query from a Codeunit.

### Steps
1. Resolve `{PREFIX}` + next free ID (Query sub-range 50145–50147).
2. Model `elements` (dataitems + columns), joins via `DataItemLink`, aggregation via `method`.
3. Add filters (`DataItemTableFilter` or column filters) as needed.
4. Update ID Ledger; emit to Handoff Contract.

### Template — Normal Query with aggregation
```al
query 50145 "VAS Sales By Customer"
{
    QueryType = Normal;
    Caption = 'VAS Sales By Customer';

    elements
    {
        dataitem(Customer; Customer)
        {
            column(CustomerNo; "No.") { Caption = 'Customer No.'; }
            column(CustomerName; Name) { Caption = 'Name'; }

            dataitem(Cust_Ledger_Entry; "Cust. Ledger Entry")
            {
                DataItemLink = "Customer No." = Customer."No.";
                SqlJoinType = LeftOuterJoin;

                column(SalesAmount; "Sales (LCY)")
                {
                    Method = Sum;
                    Caption = 'Sales (LCY)';
                }
                filter(PostingDate; "Posting Date") { }
            }
        }
    }
}
```

### Reading a query from code
```al
var
    Q: Query "VAS Sales By Customer";
begin
    Q.SetRange(PostingDate, StartDate, EndDate);
    if Q.Open() then
        while Q.Read() do
            // use Q.CustomerNo, Q.SalesAmount
    Q.Close();
end;
```

### Verify before handoff
- Prefixed name + ID in range. Joins via DataItemLink. Aggregation columns use Method. Exposed columns captioned + prefixed. Read-only. No scaffold names.
