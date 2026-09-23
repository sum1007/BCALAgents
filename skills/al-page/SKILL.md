---
name: al-page
description: Builds Business Central Page and PageExtension objects in AL. Use when creating a Card, List, or Document page, or adding fields and actions to a standard page, with ApplicationArea, ToolTip, and prefixed action names.
license: Proprietary
metadata:
  author: Votiva
  version: "1.0.0"
---

## SKILL: al-page — Page & PageExtension (Dynamics 365 Business Central, AL)

> Owned by **BC AL Generation Assistant** (@bc-basic-creation).
> Resolve `{PREFIX}`, `{ObjectIdRange}` from app-analysis §Quick Reference. NEVER guess. NEVER copy `YVS`.

### When to use
- New UI for a new table → **Page** (Card / List / Document / ListPart / API — see al-api for API pages).
- Add fields/actions to a standard page (Customer Card, Item Card, ...) → **PageExtension**.

### PageType quick guide
| Data shape | PageType |
|---|---|
| Single record edit | `Card` |
| Grid of records | `List` |
| Header + lines | `Document` (+ a ListPart for lines) |
| Embedded subpage | `ListPart` |
| Read-only stats | `CardPart` / `List` (Editable=false) |

### Rules (HARD)
- Object name `{PREFIX} {Name}`. File `src/Pages/{PREFIX}{Name}.Page.al` (or `src/PageExtensions/{PREFIX}{Std}.PageExt.al`).
- EVERY field control has `ApplicationArea` + `ToolTip`; new actions carry the `{PREFIX}` affix.
- Group/part/action names that are NEW must be prefixed. Use `addlast`/`addafter` anchors on extensions.
- No business logic in the page — call a Codeunit (see al-codeunit). Pages stay thin.
- `UsageCategory` + `ApplicationArea` set on any page that should appear in Tell-Me/search.

### Steps
1. Resolve `{PREFIX}` + next free ID (Page sub-range 50110–50124).
2. Pick PageType + SourceTable.
3. Lay out `layout` (fields with ToolTip + ApplicationArea) then `actions`.
4. Wire actions to Codeunit procedures; no inline business logic.
5. Update ID Ledger; emit to Handoff Contract.

### Template — Card Page
```al
page 50110 "VAS Delivery Note"
{
    PageType = Card;
    SourceTable = "VAS Delivery Note Header";
    Caption = 'VAS Delivery Note';
    ApplicationArea = All;
    UsageCategory = Documents;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document number.';
                }
                field("VAS Customer No."; Rec."VAS Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("VAS Post")
            {
                ApplicationArea = All;
                Caption = 'Post';
                ToolTip = 'Post the delivery note.';
                Image = Post;

                trigger OnAction()
                var
                    Mgt: Codeunit "VAS Delivery Note Mgt.";
                begin
                    Mgt.Post(Rec);
                end;
            }
        }
    }
}
```

### Template — PageExtension
```al
pageextension 50110 "VAS Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("VAS Tax Code"; Rec."VAS Tax Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the local tax code.';
            }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action("VAS Sync Tax")
            {
                ApplicationArea = All;
                Caption = 'Sync Tax';
                ToolTip = 'Synchronize the tax code from the local authority.';
                trigger OnAction()
                begin
                    // delegate to codeunit
                end;
            }
        }
    }
}
```

### Verify before handoff
- Every field has ApplicationArea + ToolTip. New actions prefixed. No business logic in page. Anchors valid on extensions. No scaffold `MyPage`.
