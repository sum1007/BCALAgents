## GitHub Copilot Orchestrator — Dynamics 365 Business Central (AL)

Plugin-level orchestrator instructions for the **d365bc-al-orchestrator** Agent Plugin.

### Routing (Authoritative)

| User intent                                                                                        | Sub-Agent to Invoke (`run_subagent`)    |
| -------------------------------------------------------------------------------------------------- | --------------------------------------- |
| Create / extend / modify Report or ReportExtension (`.al` + Layout Build)                          | **BC Report Logic Assistant**           |
| Design / populate / style Report Layout (`.docx`, `.rdl`, `.xlsx`)                                 | **BC Report Layout Assistant**          |
| Create / extend / modify non-integration, non-report AL objects                                   | **BC AL Generation Assistant**          |
| Materialize any non-integration template                                                           | **BC Resource Reuse Assistant**         |
| Create or change an inbound/outbound integration, or materialize an Integration template          | **BC Integration Generation Assistant** |
| Build / publish / fix errors / fix AppSource warnings                                              | **BC Build & Publish Assistant**        |

### Report Two-Step Pipeline (CRITICAL — Token & Layout Optimization)

When the user asks to create or modify a Report or ReportExtension:

1. Do NOT read `skills/al-report/SKILL.md` in the main orchestrator context.
2. **Step 1**: Call `BC Report Logic Assistant` (`@bc-report-logic`) to write the `.al` object (with `labels {}`, totals, and wired requestpage options) and execute the Layout Generation Build so the compiler emits the schema-valid layout file.
3. **Step 2**: If the report has a layout (not `ProcessingOnly`), call `BC Report Layout Assistant` (`@bc-report-layout`) to populate the table, headers, totals, and field bindings inside the compiler-generated layout file.
4. **Step 3**: Run Post-Creation Verification (read-only) and call `BC Build & Publish Assistant` (`@bc-build-verify`).

For an integration request, the integration agent also creates or extends its shared processing-only Generate, Cancel, and Reset reports as required by **al-api**. These supporting reports have no layout and are part of the integration handoff; do not route the integration request to the report pipeline merely because those reports are required. If the integration is implemented directly in the main chat instead of the sub-agent, still load **al-api** and satisfy its MANDATORY OUTPUT table (per-API engine + the three reports) before answering.

### Agent Map (AUTHORITATIVE — use exact display name for `run_subagent`)

| Alias (docs only)          | `agentName` (exact — copy literally)  |
| -------------------------- | ------------------------------------- |
| `@bc-basic-creation`       | `BC AL Generation Assistant`          |
| `@bc-report-logic`         | `BC Report Logic Assistant`           |
| `@bc-report-layout`        | `BC Report Layout Assistant`          |
| `@bc-build-verify`         | `BC Build & Publish Assistant`        |
| `@bc-resource-reuse`       | `BC Resource Reuse Assistant`         |
| `@bc-integration-resource` | `BC Integration Generation Assistant` |
