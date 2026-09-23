## App Analysis — Dynamics 365 Business Central (AL)

Authoritative source of truth for {PREFIX}, {ObjectIdRange}, {AppName}, and the Agent Map.
Populated by `/setup-project`. The orchestrator loads §Quick Reference ON DEMAND — never guess these values.

> If any value below still shows a `<placeholder>` → run `/setup-project` before generating code.

### Quick Reference (loaded on demand by orchestrator)

<table>
<tr><th>Key</th><th>Value</th><th>Source of truth</th></tr>
<tr><td>{PREFIX} (affix)</td><td>VAS</td><td>app.json "idRanges" registration + ruleset affix</td></tr>
<tr><td>{AppName}</td><td>Votiva VAS Localization</td><td>app.json "name"</td></tr>
<tr><td>{Publisher}</td><td>Votiva</td><td>app.json "publisher"</td></tr>
<tr><td>{ObjectIdRange}</td><td>50100 – 50149</td><td>app.json "idRanges" (from / to)</td></tr>
<tr><td>{AppVersion}</td><td>1.0.0.0</td><td>app.json "version"</td></tr>
<tr><td>{Runtime / application}</td><td>runtime 13.0 / application 24.0.0.0</td><td>app.json</td></tr>
<tr><td>{DefaultLanguage}</td><td>en-US</td><td>Translations/*.g.xlf base</td></tr>
<tr><td>{AppSourceCop}</td><td>enabled</td><td>AppSourceCop.json + ruleset</td></tr>
</table>

**HARD RULES derived from this table**
- EVERY new object/field/control/action/enum value MUST carry the `{PREFIX}` affix (AppSourceCop mandatory).
- New object IDs MUST fall inside `{ObjectIdRange}`. Pick the next free ID — NEVER hardcode an ID copied from a skill example.
- NEVER copy `YVS` (or any example prefix) into generated code — always resolve `{PREFIX}` from this table.

### ID Allocation Ledger (keep updated when objects are created)

<table>
<tr><th>Object type</th><th>Sub-range</th><th>Next free</th></tr>
<tr><td>Table / TableExtension</td><td>50100–50109</td><td>50100</td></tr>
<tr><td>Page / PageExtension</td><td>50110–50124</td><td>50110</td></tr>
<tr><td>Codeunit</td><td>50125–50134</td><td>50125</td></tr>
<tr><td>Report / ReportExtension</td><td>50135–50139</td><td>50135</td></tr>
<tr><td>Enum / EnumExtension</td><td>50140–50144</td><td>50140</td></tr>
<tr><td>Query / XMLport / Interface</td><td>50145–50147</td><td>50145</td></tr>
<tr><td>PermissionSet / Entitlement</td><td>50148–50149</td><td>50148</td></tr>
</table>

### Object Naming Matrix

<table>
<tr><th>Scenario</th><th>Pattern</th><th>Example</th></tr>
<tr><td>New object</td><td>{PREFIX} {Name}</td><td>"VAS Sales Invoice Header"</td></tr>
<tr><td>New field / control / action</td><td>{PREFIX} {Name}</td><td>"VAS Tax Code"</td></tr>
<tr><td>Table extension</td><td>"{PREFIX} {StdObject} Ext" extends {StdObject}</td><td>"VAS Customer Ext" extends Customer</td></tr>
<tr><td>Page extension</td><td>"{PREFIX} {StdObject} Ext" extends "{StdObject}"</td><td>"VAS Item Card Ext" extends "Item Card"</td></tr>
<tr><td>Enum extension</td><td>"{PREFIX} {StdEnum} Ext" extends "{StdEnum}"</td><td>"VAS Payment Method Ext"</td></tr>
<tr><td>Event subscriber (Codeunit)</td><td>{PREFIX}{Target}Subscriber</td><td>VASSalesPostSubscriber</td></tr>
<tr><td>Install / Upgrade codeunit</td><td>"{PREFIX} {AppName} Install"</td><td>"VAS Localization Install" (Subtype=Install)</td></tr>
<tr><td>Permission set</td><td>{PREFIX}-{AREA}</td><td>VAS-ALL, VAS-READ</td></tr>
</table>

### File / Folder Layout (src tree)
src/
  Tables/            {PREFIX}{Name}.Table.al
  TableExtensions/   {PREFIX}{Std}.TableExt.al
  Pages/             {PREFIX}{Name}.Page.al
  PageExtensions/    {PREFIX}{Std}.PageExt.al
  Codeunits/         {PREFIX}{Name}.Codeunit.al
  Reports/           {PREFIX}{Name}.Report.al  (+ .rdlc / .docx layout alongside)
  Enums/             {PREFIX}{Name}.Enum.al
  Queries/           {PREFIX}{Name}.Query.al
  Permissions/       {PREFIX}{Name}.PermissionSet.al
Translations/        {AppName}.g.xlf + per-language *.xlf

### Agent Map (AUTHORITATIVE — keep in sync with instructions/copilot-instructions.md)

Always use the **exact display name** for run_subagent(agentName=...). Never use the alias.

<table>
<tr><th>Alias (docs only)</th><th>agentName (exact — copy literally)</th><th>Responsibility</th></tr>
<tr><td>@bc-basic-creation</td><td>BC AL Generation Assistant</td><td>Create/extend/modify any AL object from scratch.</td></tr>
<tr><td>@bc-build-verify</td><td>BC Build & Publish Assistant</td><td>Compile, app.json bump, publish to sandbox, fix CodeCop/AppSourceCop.</td></tr>
<tr><td>@bc-resource-reuse</td><td>BC Resource Reuse Assistant</td><td>Materialize non-integration templates from BCALResources.</td></tr>
<tr><td>@bc-integration-resource</td><td>BC Integration Generation Assistant</td><td>Materialize API Page/Query/web-service integration templates.</td></tr>
</table>
