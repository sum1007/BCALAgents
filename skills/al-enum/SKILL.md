---
name: al-enum
description: Defines Business Central Enum and EnumExtension objects in AL. Use when creating an extensible choice list, adding values to a standard enum such as Payment Method, or replacing an Option field, with prefixed captioned values.
license: Proprietary
metadata:
  author: Votiva
  version: "1.0.0"
---

## SKILL: al-enum — Enum & EnumExtension (Dynamics 365 Business Central, AL)

> Owned by **BC AL Generation Assistant** (@bc-basic-creation).
> Resolve `{PREFIX}`, `{ObjectIdRange}` from app-analysis §Quick Reference. NEVER guess. NEVER copy `YVS`.

### When to use
- New choice list for a field/parameter → **Enum** (always prefer over `Option`).
- Add values to a standard/extensible enum (e.g. "Payment Method") → **EnumExtension**.

### Rules (HARD)
- Object name `{PREFIX} {Name}`. File `src/Enums/{PREFIX}{Name}.Enum.al`.
- Set `Extensible = true` on your enums so others can extend them.
- EVERY enum VALUE carries the `{PREFIX}` affix (AppSourceCop) and a `Caption`.
- Value ordinals: leave gaps (0,10,20…) so downstream extensions can insert. Never renumber shipped values (breaking change).
- EnumExtension can only extend an enum whose `Extensible = true`.

### Steps
1. Resolve `{PREFIX}` + next free ID (Enum sub-range 50140–50144).
2. Decide Enum vs EnumExtension.
3. Add values with prefix + Caption; keep gaps in ordinals.
4. Update ID Ledger; emit to Handoff Contract (set translationFileTouched if captions added).

### Template — Enum
```al
enum 50140 "VAS Invoice Kind"
{
    Extensible = true;
    Caption = 'VAS Invoice Kind';

    value(0; "VAS None") { Caption = 'None'; }
    value(10; "VAS Commercial") { Caption = 'Commercial'; }
    value(20; "VAS Adjustment") { Caption = 'Adjustment'; }
}
```

### Template — EnumExtension
```al
enumextension 50140 "VAS Payment Method Ext" extends "Payment Method"
{
    value(50140; "VAS QR Transfer") { Caption = 'QR Transfer'; }
    value(50141; "VAS E-Wallet") { Caption = 'E-Wallet'; }
}
```

### Using an enum on a table field
```al
field(10; "VAS Invoice Kind"; Enum "VAS Invoice Kind")
{
    Caption = 'Invoice Kind';
    DataClassification = CustomerContent;
}
```

### Verify before handoff
- Prefixed name + ID in range. `Extensible = true`. Every value prefixed + captioned. Ordinal gaps kept. EnumExtension target is extensible. No scaffold names.
