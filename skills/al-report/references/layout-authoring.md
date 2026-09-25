# Report Layout Authoring — reference

Full layout lifecycle for the al-report skill. Summary lives in SKILL.md.
Owned by **BC Report Generation Assistant**.

## The four layout types

| Type | File | Authored with | Use for |
| --- | --- | --- | --- |
| **Word** | `.docx` | Microsoft Word | Business documents, letters, email bodies. Default choice. |
| **Excel** | `.xlsx` | Microsoft Excel | Analytics, data dumps. Formulas, PivotTables, PivotCharts, PowerQuery. |
| **RDLC** | `.rdl` / `.rdlc` | SQL Server Report Builder, or Visual Studio + RDLC Report Designer | Pixel-precise or legacy output only. |
| **External** | varies | external source | Layout originating outside the app. |

Two independent concepts:
- **Layout Type** — the kind of file the layout is based on.
- **Layout Source** — where the layout came from: built-in (shipped by Microsoft) or custom (yours).

Built-in layouts **cannot be modified**. Use them only as a starting point for a custom layout.
A single report may carry multiple layouts and switch between them.

## Build-first lifecycle (the rule that prevents schema failures)

```
declare rendering { layout(...) }  ->  BUILD (Ctrl+Shift+B)  ->  open generated file  ->  fill table  ->  Ctrl+F5
```

**Never hand-write the layout file.** BC validates layouts against its own schema. A fabricated file
fails at render time with errors like:

```
No declaration found for the report definition element 'DataField' ... /2016/01/reportdefinition
```

The build produces a file that is always schema-correct and already contains the **Custom XML part**
representing the dataset. Humans and agents only fill the table (Tablix) inside it.

### Word — step by step

1. Open the report object; go to the `rendering` section (create it if missing).
2. Add a layout entry of `Type = Word` and set `LayoutFile` to a valid `.docx` path.
3. `Ctrl + Shift + B` → the build generates the `.docx` including the Custom XML part.
4. Right-click the `.docx` → open in Word.
5. Insert a table; drag fields from the **Word add-in data picker** (or the legacy XML Mapping Pane) into the cells.
6. Save, keeping the filename unchanged.
7. `Ctrl + F5` to render.

A Word layout typically uses tables to arrange content; cells hold data fields, text, or pictures.
Word gives you margins, page orientation, line spacing, advanced headers/footers, sections for
switching layout style mid-document, and full typography control.

### Excel — step by step

Same declaration + build cycle, `Type = Excel`, `.xlsx` path. Author with normal Excel features:
formulas, PivotTables, PivotCharts, slicers, charts, PowerQuery.

### RDLC — step by step

1. Delete any hand-written `.rdl`.
2. Keep the declaration: `rendering { layout("{PREFIX}{Name}.RDLC") { Type = RDLC; LayoutFile = './src/Reports/{PREFIX}{Name}.rdl'; } }`
3. `Ctrl + Shift + B` → the build creates a valid empty `.rdl` with the correct schema.
4. Right-click the `.rdl` → Open Externally (Report Builder) → insert a Table → drag dataset fields in → Save.
5. `Ctrl + F5` to render.

**File-extension trap:** Report Builder recognizes only `.rdl`, not `.rdlc`. Layout files exported from
BC are `.rdlc` — rename them to `.rdl` before opening in Report Builder.

## Designing the dataset FOR the layout author

The person designing the layout never sees your AL code. They see labels, dataitems, and fields in the
data picker. Therefore:

- Give labels, dataitems, and columns **friendly, self-describing names**.
- Use `IncludeCaption` so captions travel with the data instead of being retyped in the layout.
- Format values in the dataset so the layout stays simple.
- Verify the dataset before authoring: run the report and export the result as **raw data to Excel**.

## System dataitems (BC 2025 release wave 1 / v26 and later)

Word and Excel layouts can read report and request metadata through two system dataitems that appear in
the XML Mapping pane. They are **not part of the dataset** — they exist only in the layout XML.

| Dataitem | Contains |
| --- | --- |
| `ReportMetadata` | `ExtensionID`, `ExtensionName`, `ExtensionPublisher`, `ExtensionVersion`, `ReportID`, `ReportName`, `AboutThisReportTitle` |
| `ReportRequest` | request-time metadata |

Use these instead of adding common fields such as company name or user name to the dataset. It keeps the
dataset lean and guarantees consistent naming and placement in the data picker.

Confirm the target environment is v26+ before relying on this.

## Report extension layouts — the manual selection step

A layout shipped inside a **report extension is NOT applied automatically** after deployment.

The user must open the **Report Layout Selection** page in Business Central and choose the new layout
from the **Custom Layout Description** dropdown for that report.

Always surface this to the user in the handoff — otherwise the layout silently never appears.

## Troubleshooting

| Symptom | Root cause | Fix |
| --- | --- | --- |
| `No declaration found for ... 'DataField'` | Layout XML was hand-written | Delete it; let the build regenerate; fill only the table |
| Report Builder cannot open the file | File is `.rdlc` | Rename to `.rdl` |
| Field appears in the designer but prints **blank** | `DataItemLink` / `DataItemLinkReference` wrong, or the dataitem is not actually a child | Fix indentation and the link pair; for one or two values prefer a variable over an extra dataitem |
| Layout not linked to the report | Layout alias invented instead of derived | Use the deterministic name `{PREFIX}{Name}.{Type}` and match `DefaultRenderingLayout` |
| Report extension layout never appears | Not selected after deploy | Report Layout Selection → Custom Layout Description |
| Layout file missing after build | Build failed before emitting the artifact | Read the build error; do NOT fabricate the file |
| Report slow on multi-table joins | Deeply nested dataitems | Switch the source to a Query object |
| Email body renders wrong | RDLC used for email | Email layouts must be Word |
