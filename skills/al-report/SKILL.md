---
name: al-report
description: Creates Business Central Report and ReportExtension objects in AL, covering the three report scenarios (analytical, document, processing-only), the mandatory section order, dataset design for layout authoring, and the build-first layout lifecycle. Use when building a printout or analysis report, choosing a Word, Excel, or RDLC layout, defining the dataset and request page, or extending a standard report.
license: Proprietary
metadata:
  author: Votiva
  version: "1.0.1"
---

# SKILL: al-report — Report & ReportExtension (Dynamics 365 Business Central, AL)

Owned by **BC Report Generation Assistant** (`@bc-report-generation`).
Resolve `{PREFIX}`, `{ObjectIdRange}` from app-analysis §Quick Reference. NEVER guess. NEVER copy VAS from examples.

## Step 0 — Classify the scenario FIRST

A report object serves exactly one of three scenarios. Picking wrong is the most expensive mistake.

| Scenario            | Purpose                                             | Layout required | Preferred layout |
| ------------------- | --------------------------------------------------- | --------------- | ---------------- |
| **Analytical**      | Data for online consumption / analysis              | Yes             | Excel            |
| **Document**        | Printed or PDF output (invoice, voucher, statement) | Yes             | Word             |
| **Processing-only** | No output at all; request page drives an operation  | **No**          | none             |

Any report that is viewed, printed, or saved from the client MUST have a layout.
Processing-only reports set `ProcessingOnly = true` and have NO `rendering` section.

## Section order (MANDATORY — compile-breaking if wrong)

```al
report 50135 "VAS Customer Statement"
{
    // 1. properties
    dataset { }      // 2. required
    requestpage { }  // 3. optional
    rendering { }    // 4. optional, but REQUIRED for any report with a layout
    // 5. AL code: var, triggers, procedures
}
```

Snippet `treport` generates the skeleton. `Ctrl + Space` for IntelliSense.

## Layout choice (Rule §15)

| Need                                    | Layout                    | File    | Tool                      |
| --------------------------------------- | ------------------------- | ------- | ------------------------- |
| Business document / letter / email body | **Word** — preferred      | `.docx` | Microsoft Word            |
| Data dump / analytics / pivot           | **Excel**                 | `.xlsx` | Microsoft Excel           |
| Pixel-precise legacy                    | RDLC — only when required | `.rdl`  | SQL Server Report Builder |

- Email body layouts MUST be Word. RDLC is not supported for email.
- The layout file lives **beside** the report `.al` in `src/Reports/`.
- Report Builder only opens `.rdl`. Files exported from BC are `.rdlc` — rename before editing.

## Build-first layout rule (HARD — never violate)

**NEVER hand-write a layout file.** BC validates layouts against its own schema and rejects fabricated
files with errors such as _"No declaration found for the report definition element 'DataField'"_.

Correct lifecycle:

1. Declare the `rendering` section with a deterministic layout name and `LayoutFile` path.
2. Build the extension (`Ctrl + Shift + B`) → the build emits a schema-correct layout file containing the Custom XML part.
3. Open the generated file and fill only the table / Tablix with dataset fields.
4. `Ctrl + F5` to render.

The skill NEVER emits `<Report>`, namespaces, `<DataSets>`, `<Fields>`, or `<DataField>`.

## Deterministic layout naming (prevents "layout not linked")

| Item        | Pattern                              | Example                                   |
| ----------- | ------------------------------------ | ----------------------------------------- |
| Layout name | `{PREFIX}{Name}.{Type}`              | `"VASCustomerStatement.Word"`             |
| Layout file | `./src/Reports/{PREFIX}{Name}.{ext}` | `./src/Reports/VASCustomerStatement.docx` |

`DefaultRenderingLayout` MUST reference that exact layout name. Never invent an alias.

## Dataset design rules (HARD)

- A dataitem is a **table**. A column is a field, a **variable**, an **expression**, or a **text constant**.
- Each dataitem is iterated over ALL records of its table; filters are applied, then the dataset is built. Deep nesting multiplies rows — watch performance.
- **Format values in the dataset, not in the layout.** Reduce decimal precision, format dates/currencies here.
- Use `IncludeCaption = true` to pull table field captions into the dataset instead of hardcoding text in the layout.
- **Use friendly names** for labels, dataitems, and columns — the layout designer picks them from the Word data picker. `CustLedgerEntry.DocumentNo` is usable; `DI2_Col7` is not.
- Linking dataitems — set BOTH properties on the **child**:
  ```al
  DataItemLinkReference = Customer;
  DataItemLink = "Customer No." = field("No.");
  ```
  Multiple pairs are comma-separated. The referenced item may be the parent or a further ancestor.
  `DataItemLinkReference` defaults to the nearest preceding dataitem with lower indentation.
  Setting these on a dataitem that is NOT a child has **no effect and fails silently**.
- Heavy logic belongs in a Codeunit (see al-codeunit). The report shapes data and triggers only.
- For expensive multi-table joins, consider a **Query object** as the source: declare a global query
  variable, use `Integer` as the dataitem, and drive it from `OnPreDataItem` + `OnAfterGetRecord`.
- **Verify the dataset before authoring the layout** — run the report and export the result as raw data to Excel.

## Rules (HARD)

- Object name `{PREFIX} {Name}`. File `src/Reports/{PREFIX}{Name}.Report.al`.
- **Every column and label has a Caption.** Request-page fields carry `{PREFIX}` + `ApplicationArea` + `ToolTip`.
- Set `DefaultRenderingLayout` and declare `rendering { layout(...) }` for every report that has a layout.
- `UsageCategory` + `ApplicationArea` if the report must appear in Tell Me.
- Report IDs come from the **Report** sub-range; ReportExtension IDs from the **ReportExtension** sub-range. They are separate — a report and a report extension must NOT share an ID.
- A report extension's layout is **not** applied automatically after deploy. The user must select it on the **Report Layout Selection** page (Custom Layout Description).
- Ship/extend a PermissionSet covering the report object.
- No breaking changes on shipped reports — obsoletion cycle only.

## Steps

1. Classify the scenario (analytical / document / processing-only).
2. Resolve `{PREFIX}` + next free ID from the correct sub-range.
3. Define the dataset; verify it by exporting raw data to Excel.
4. Define the request page (filters, options) with prefix + ApplicationArea + ToolTip.
5. Declare `rendering` with the deterministic layout name; set `DefaultRenderingLayout`.
6. **Build** to generate the layout artifact. Never hand-write it.
7. Author the layout (human task) — fill the table with dataset fields.
8. Update the ID Ledger; set `translationFileTouched` if captions were added; emit the Handoff Contract.

## Templates

| Need                               | Template file                               |
| ---------------------------------- | ------------------------------------------- |
| Document report, Word layout       | `templates/WordDocumentReport.Report.al`    |
| Analytical report, Excel layout    | `templates/ExcelAnalyticalReport.Report.al` |
| Processing-only report (no layout) | `templates/ProcessingOnlyReport.Report.al`  |
| Extend a standard report           | `templates/ReportExtension.ReportExt.al`    |

Full layout lifecycle, the four layout types, system dataitems, and troubleshooting:
**`references/layout-authoring.md`**

## Verify before handoff

- Scenario classified; processing-only has NO rendering section and NO layout file.
- Section order correct: properties → dataset → requestpage → rendering → code.
- Prefixed object name; ID inside the correct sub-range; Report and ReportExtension IDs not colliding.
- **Every column and label captioned.** Request-page fields prefixed + ApplicationArea + ToolTip.
- Layout name deterministic; `DefaultRenderingLayout` matches it exactly.
- **Layout file exists on disk beside the `.al` and was generated by the build** — not hand-written.
- Dataset verified by raw-data export. Friendly names used throughout.
- No scaffold names. PermissionSet covers the report.
