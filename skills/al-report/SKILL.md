---
name: al-report
description: "Reference templates for Business Central Reports. ORCHESTRATOR RULE: Do NOT execute report creation in the main chat context. Always delegate Step 1 (.al creation + layout generation build) to 'BC Report Logic Assistant' and Step 2 (layout styling) to 'BC Report Layout Assistant'."
license: Proprietary
metadata:
  author: Votiva
  version: "2.0.0"
---

# SKILL: al-report — Compact Reference & Templates

## Two-Agent Workflow (Token & Layout Optimized)
1. **BC Report Logic Assistant (`@bc-report-logic`)**: Classifies scenario, writes `.Report.al` / `.ReportExt.al` using one template from `templates/`, and runs the AL build so the compiler emits the schema-valid layout file.
2. **BC Report Layout Assistant (`@bc-report-layout`)**: Runs `scripts/author_layout.py` (or edits RDLC `<ReportSections>`) to populate visual tables, headers, totals, and bindings inside the compiler-generated layout file without touching `<DataSets>` or `customXml/item1.xml`.

## Scenario & Template Mapping

| Scenario | Purpose | Layout Type | Template File |
| :--- | :--- | :--- | :--- |
| **Document** | Printout / PDF / Email body | `Word` (`.docx`) | `templates/WordDocumentReport.Report.al` |
| **Analytical** | Online analysis / PivotTable | `Excel` (`.xlsx`) | `templates/ExcelAnalyticalReport.Report.al` |
| **Processing-only** | Batch task, no print output | None (`ProcessingOnly = true`) | `templates/ProcessingOnlyReport.Report.al` |
| **Extension** | Add fields/layout to standard report | `Word` / `Excel` / `RDLC` | `templates/ReportExtension.ReportExt.al` |

## Hard AL Report Rules (Summary)
- **Section Order**: `properties` → `dataset` → `requestpage` → `rendering` → `labels` → `var / triggers / procedures`.
- **ID Separation**: `Report` IDs and `ReportExtension` IDs must come from separate sub-ranges and never collide.
- **Deterministic Naming**: Layout name MUST be `"{PREFIX}{Name}.{Type}"` and match `DefaultRenderingLayout` (for `Report` objects with a layout). File path: `'./src/Reports/{PREFIX}{Name}.{ext}'`.
- **Labels in `labels { }`**: Static captions (title, page, total, signature labels) MUST be declared in the `labels { }` section so they are exported to the layout XML picker.
- **DataItem Linking**: Set BOTH `DataItemLinkReference` and `DataItemLink` on child dataitems.
- **Formatting vs Raw Types**:
  - **Word / RDLC**: Format decimals/dates in AL (`Format(...)`) AND include pre-calculated `Total...` columns on the parent dataitem.
  - **Excel**: Output raw `Decimal` and `Date` columns so Excel formulas and PivotTables work natively.
- **Wire Request Page Fields**: Every option on `requestpage` must be used in triggers (`if not ShowDetails then CurrReport.Break();` on the child dataitem).
