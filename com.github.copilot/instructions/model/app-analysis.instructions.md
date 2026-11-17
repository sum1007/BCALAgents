## App Analysis — Dynamics 365 Business Central (AL)

Authoritative source of truth for {PREFIX}, {ObjectIdRange}, {AppName}, and the Agent Map.
Populated by `/setup-project` (or resolved via `app.json` fallback in plugin mode).

### Quick Reference (loaded on demand)

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

### ID Allocation Ledger (Report & ReportExtension separated)

<table>
<tr><th>Object type</th><th>Sub-range</th><th>Next free</th></tr>
<tr><td>Table / TableExtension</td><td>50100–50109</td><td>50100</td></tr>
<tr><td>Page / PageExtension</td><td>50110–50124</td><td>50110</td></tr>
<tr><td>Codeunit</td><td>50125–50134</td><td>50125</td></tr>
<tr><td>Report</td><td>50135–50137</td><td>50135</td></tr>
<tr><td>ReportExtension</td><td>50138–50139</td><td>50138</td></tr>
<tr><td>Enum / EnumExtension</td><td>50140–50144</td><td>50140</td></tr>
<tr><td>Query / XMLport / Interface</td><td>50145–50147</td><td>50145</td></tr>
<tr><td>PermissionSet / Entitlement</td><td>50148–50149</td><td>50148</td></tr>
</table>

### Agent Map (AUTHORITATIVE)

<table>
<tr><th>Alias (docs only)</th><th>agentName (exact — copy literally)</th><th>Responsibility</th></tr>
<tr><td>@bc-basic-creation</td><td>BC AL Generation Assistant</td><td>Create/extend/modify non-report AL objects from scratch.</td></tr>
<tr><td>@bc-report-logic</td><td>BC Report Logic Assistant</td><td>Step 1 of Report: Create Report/ReportExtension (.al) and run Layout Generation Build.</td></tr>
<tr><td>@bc-report-layout</td><td>BC Report Layout Assistant</td><td>Step 2 of Report: Populate and style compiler-generated layout (.docx, .rdl, .xlsx).</td></tr>
<tr><td>@bc-build-verify</td><td>BC Build & Publish Assistant</td><td>Compile, app.json bump, publish to sandbox, fix CodeCop/AppSourceCop.</td></tr>
<tr><td>@bc-resource-reuse</td><td>BC Resource Reuse Assistant</td><td>Materialize non-integration templates from BCALResources.</td></tr>
<tr><td>@bc-integration-resource</td><td>BC Integration Generation Assistant</td><td>Materialize API Page/Query/web-service integration templates.</td></tr>
</table>
