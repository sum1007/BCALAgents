---
name: al-codeunit
description: Writes Business Central Codeunit logic, event subscribers, and Install or Upgrade codeunits in AL. Use when adding posting or business logic, subscribing to a base event, raising integration events, or seeding setup data on install.
license: Proprietary
metadata:
  author: Votiva
  version: "1.0.0"
---

## SKILL: al-codeunit — Codeunit, Event Subscribers & Install/Upgrade (Dynamics 365 Business Central, AL)

> Owned by **BC AL Generation Assistant** (@bc-basic-creation).
> Resolve `{PREFIX}`, `{ObjectIdRange}` from app-analysis §Quick Reference. NEVER guess. NEVER copy `YVS`.

### When to use
- Business logic / posting / calculations → **Codeunit** (`Subtype = Normal`).
- React to a base app event without patching it → **Event subscriber codeunit** (`EventSubscriberInstanceType = StaticAutomatic`).
- One-time data setup on install → **Install codeunit** (`Subtype = Install`).
- Data migration between versions → **Upgrade codeunit** (`Subtype = Upgrade`).

### Rules (HARD)
- Object name `{PREFIX} {Name}` (or `{PREFIX}{Target}Subscriber`). File `src/Codeunits/{PREFIX}{Name}.Codeunit.al`.
- Integrate via **event subscribers**, never edit base objects. Prefer standard published integration/business events.
- Public API: expose `procedure` (external) vs `local procedure` (internal). Raise your own events with `[IntegrationEvent(false, false)]` for extensibility.
- Errors: use `Error()` / `ErrorInfo` with actionable text; no silent `exit(false)` on failure paths. Telemetry via `Session.LogMessage` — never log secrets/PII.
- English-only content. Every new object prefixed.

### Steps
1. Resolve `{PREFIX}` + next free ID (Codeunit sub-range 50125–50134).
2. Pick Subtype (Normal / Install / Upgrade) or subscriber pattern.
3. Write thin, testable procedures; publish integration events for extension points.
4. For subscribers: find the correct base event via `find_symbol` (do NOT invent event signatures).
5. Update ID Ledger; emit to Handoff Contract.

### Template — Business logic codeunit
```al
codeunit 50125 "VAS Delivery Note Mgt."
{
    procedure Post(var Header: Record "VAS Delivery Note Header")
    var
        AlreadyPostedErr: Label 'Delivery note %1 is already posted.', Comment = '%1 = document no.';
    begin
        Header.TestField("No.");
        if Header."VAS Posting Date" = 0D then
            Header."VAS Posting Date" := WorkDate();
        OnBeforePost(Header);
        // ... posting logic ...
        OnAfterPost(Header);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePost(var Header: Record "VAS Delivery Note Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPost(var Header: Record "VAS Delivery Note Header")
    begin
    end;
}
```

### Template — Event subscriber
```al
codeunit 50126 "VAS Sales Post Subscriber"
{
    EventSubscriberInstanceType = StaticAutomatic;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure HandleOnAfterPostSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        // react without touching the base object
    end;
}
```

### Template — Install codeunit
```al
codeunit 50127 "VAS Localization Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitSetup();
    end;

    local procedure InitSetup()
    begin
        // seed default setup records (idempotent)
    end;
}
```

### Verify before handoff
- Prefixed name + ID in range. Subscriber uses a REAL base event (verified via symbols). Errors actionable, no secret logging. Extension points via IntegrationEvent. No scaffold names.
