# BCALAgents

BCALAgents is a GitHub Copilot agent plugin for building and maintaining
Dynamics 365 Business Central extensions written in AL. It packages specialized
agents, reusable AL skills, project setup guidance, and workflow rules for
common development tasks.

Current plugin version: **1.3.0**.

The plugin is designed to help developers create AL objects, build reports and
layouts, reuse integration or feature templates, and compile and publish an app
to a Business Central sandbox. It is not a Business Central runtime extension
and does not replace review, testing, or deployment approvals.

## What it includes

### Specialized agents

| Agent | What it does |
| --- | --- |
| **BC AL Generation Assistant** | Creates or extends non-report AL objects such as tables, pages, codeunits, enums, queries, and permission sets. |
| **BC Report Logic Assistant** | Creates report AL objects and generates a schema-correct report layout file. |
| **BC Report Layout Assistant** | Populates and styles a compiler-generated Word, Excel, or RDLC report layout. |
| **BC Build & Publish Assistant** | Compiles the app, handles `app.json` version/dependency changes, resolves analyzer findings, and publishes to a sandbox. |
| **BC Resource Reuse Assistant** | Adapts non-integration templates from `BCALResources` to the current app's prefix and object ID range. |
| **BC Integration Generation Assistant** | Adapts API and other integration templates from `BCALResources` to the current app. |

Agents hand work to the next appropriate stage. For example, report creation
uses the Report Logic Assistant first and then the Report Layout Assistant;
object creation is followed by verification and, when requested, the Build &
Publish Assistant.

### AL skills

The plugin provides eight focused skills: `al-api`, `al-codeunit`, `al-enum`,
`al-page`, `al-permissionset`, `al-query`, `al-report`, and `al-table`. They
provide object-specific patterns, checklists, and templates to guide the
agents.

### Project setup and guardrails

The `/setup-project` command reads an AL app's `app.json` and AppSourceCop
ruleset to establish project context, including the registered affix and
available object ID range. It initializes the app-analysis reference and ID
allocation ledger so agents can use project values rather than guessing.

The workflow also emphasizes AppSource naming and ID rules, permission sets,
data classification, translations, report layout correctness, and safe
handling of integration credentials.

### Integration processing workflow

The integration workflow now treats an integration request as a complete
processing feature, not only an API endpoint. For each integration, the
Integration Generation Assistant checks for and creates or reuses:

- Shared integration history, enums, history list page, and one shared set of
  **Generate Data**, **Cancel Data**, and **Reset Data** processing-only reports
  per app.
- A per-integration processing engine, typed detail log table, detail list page,
  and API handler or outbound sync codeunit.
- API-key dispatch from all three processing reports to the integration's
  engine, history-page actions to run those reports, and permissions for the
  complete feature.

The reports are shared across inbound and outbound integrations. Their
processing behavior must follow the actual integration contract; credentials
must not be hardcoded, and sensitive values must be masked before logging.

## Requirements

- Visual Studio Code with GitHub Copilot enabled and signed in.
- Agent plugin support enabled in VS Code (`chat.plugins.enabled`).
- The Microsoft **AL Language** extension for compiling or publishing AL apps.
- A Business Central development or sandbox environment and the required
  access to it for publish operations.

## Install

1. Install Visual Studio Code and sign in to GitHub Copilot.
2. In VS Code settings, enable agent plugins:

   ```json
   {
     "chat.plugins.enabled": true
   }
   ```

3. Open the Command Palette and run **Chat: Install Plugin from Source**.
4. Enter either the repository URL
   `https://github.com/sum1007/BCALAgents` or the path to a local checkout of
   this repository. The folder should contain `plugin.json`.
5. Choose **User** to install it for your account, or **Workspace** to install
   it for the current workspace.
6. Open your Business Central AL project and start a new Copilot chat. Confirm
   the plugin is installed and enabled in the Agent Customizations editor.

You can also open the Agent Customizations editor from the Chat view, select
**Plugins**, and use the add (`+`) button to install from a repository or local
folder.

## User manual

### 1. Prepare an AL project

Open the folder containing the AL app's `app.json` in VS Code. For a new project
or after changing `app.json`, run:

```text
/setup-project
```

The command reads the app metadata and AppSourceCop ruleset, then sets up
project-specific naming and ID allocation context. If it cannot determine the
registered affix or licensed range, provide the correct value or ruleset; the
agents are instructed not to invent one.

### 2. Ask for the task in Copilot Chat

Describe the desired Business Central change and any relevant business rules.
For example:

```text
Create a table extension for Customer to store an external reference number.
```

```text
Create a Word report for posted sales invoices with the customer, lines,
totals, and a request-page date filter.
```

```text
Build and publish this AL app to my development sandbox.
```

For an integration, describe the API contract, direction (inbound or outbound),
and the expected processing or retry behavior. For example:

```text
Create an inbound customer upsert API. Use this request contract: [fields and
types]. Generate should process pending records; Reset should make failed
records retryable. Do not invent a partner-side cancel operation.
```

Copilot routes the request to a suitable agent. You can also select one of the
plugin's agents directly from the agent picker. Mention the desired template
name and its source when requesting template reuse.

### 3. Follow the workflow handoffs

- For standard AL objects, the AL Generation Assistant creates the objects and
  hands off for verification and build when appropriate.
- For reports, the Report Logic Assistant creates the `.al` object and
  compiler-generated layout. The Report Layout Assistant then authors the
  generated layout.
- For integrations or reusable features, the matching resource agent adapts
  the requested template, then hands off for verification and build.
- The Build & Publish Assistant performs compilation and analyzer work, and
  publishes to a sandbox when that is part of the request.

Review the changed files and build/publish result in VS Code before using the
changes in a shared environment.

### 4. Use resource templates (if applicable)

The resource agents use configured template names in
`com.github.copilot/config/`. The resource trees themselves are expected at
`BCALResources/Function/` and `BCALResources/Integration/` in the relevant
workspace; they are not included in this plugin repository. Make the required
resource tree available before asking an agent to materialize one of those
templates.

## Notes and limitations

- Build and publish tasks require the AL toolchain, downloaded symbols, and
  access to a suitable Business Central environment.
- The Build & Publish Assistant is intended to publish to a sandbox. Do not
  use it as a production deployment process.
- The plugin provides guidance and automation, but generated code and
  deployment actions still require developer review.
- UI captions, labels, tooltips, comments, and generated AL content follow the
  plugin's English-only rules; Copilot responses follow the user's language.

## Repository layout

```text
agents/                 Copilot agent definitions
com.github.copilot/     Copilot instructions, setup command, and configuration
skills/                 AL skills, templates, and supporting references
plugin.json             Agent plugin manifest
```

## License

The AL skills identify their content as proprietary. Follow the licensing and
usage terms applicable to your organization when using or redistributing this
repository.
