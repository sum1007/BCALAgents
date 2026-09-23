---
name: al-permissionset
description: Creates Business Central PermissionSet and PermissionSetExtension objects in AL. Use when granting access to a feature's objects, shipping full and read-only sets, or extending a standard permission set for AppSource compliance.
license: Proprietary
metadata:
  author: Votiva
  version: "1.0.0"
---

## SKILL: al-permissionset — PermissionSet & PermissionSetExtension (Dynamics 365 Business Central, AL)

> Owned by **BC AL Generation Assistant** (@bc-basic-creation). Every functional feature MUST ship one (Rule §6).
> Resolve `{PREFIX}`, `{ObjectIdRange}` from app-analysis §Quick Reference. NEVER guess. NEVER copy `YVS`.

### When to use
- Any new functional set of objects (tables/pages/codeunits/reports) → ship a **PermissionSet** covering them.
- Add object permissions to a base/standard permission set → **PermissionSetExtension**.

### Rules (HARD)
- Object name `{PREFIX}-{AREA}` (e.g. `VAS-ALL`, `VAS-READ`). File `src/Permissions/{PREFIX}{Name}.PermissionSet.al`.
- Cover EVERY object created by the feature (TableData RIMD + object execution).
- Prefer a coded `permissionset` object over legacy XML permission files.
- Provide at least: one full set (`-ALL`, RIMD) and optionally a read-only set (`-READ`, R only) for reviewers/reporting.
- Assign to users/roles at deployment; without it, objects are invisible even after publish (see error-library "object not visible").

### Steps
1. Resolve `{PREFIX}` + next free ID (PermissionSet sub-range 50148–50149).
2. Enumerate every object from the feature's Handoff Contract.
3. Grant `tabledata "X" = RIMD` + object execution for pages/codeunits/reports/queries.
4. Add a read-only variant if useful.
5. Emit to Handoff Contract.

### Template — Full PermissionSet
```al
permissionset 50148 "VAS-ALL"
{
    Assignable = true;
    Caption = 'VAS Localization - Full';

    Permissions =
        tabledata "VAS Delivery Note Header" = RIMD,
        table "VAS Delivery Note Header" = X,
        page "VAS Delivery Note" = X,
        codeunit "VAS Delivery Note Mgt." = X,
        report "VAS Customer Statement" = X,
        query "VAS Sales By Customer" = X;
}
```

### Template — Read-only PermissionSet
```al
permissionset 50149 "VAS-READ"
{
    Assignable = true;
    Caption = 'VAS Localization - Read Only';

    Permissions =
        tabledata "VAS Delivery Note Header" = R,
        page "VAS Delivery Note" = X,
        report "VAS Customer Statement" = X;
}
```

### Template — PermissionSetExtension
```al
permissionsetextension 50148 "VAS Sales Ext" extends "D365 SALES"
{
    Permissions =
        tabledata "VAS Delivery Note Header" = RIMD,
        page "VAS Delivery Note" = X;
}
```

### Verify before handoff
- Prefixed name (`{PREFIX}-{AREA}`) + ID in range. `Assignable = true`. Covers ALL feature objects (tabledata RIMD + execution X). No object left uncovered. No scaffold names.
