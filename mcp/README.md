# SwiftUI Motion MCP server

Lets AI coding tools search SwiftUI Motion Library and pull an effect's usage, implementation notes and full source straight into your project.

It is a single file with no dependencies (Node 18+). From a checkout it reads `Docs/motion-catalog.json`; run on its own, it downloads the catalog from GitHub.

## Tools

| Tool | What it does |
|---|---|
| `list_motion_effects` | Lists effects with their one-line API. Optional `query`, `component` (text, button, card, shape, background, number, particle) and `trigger` (appear, tap, press, drag, hover, scroll, change, loop). |
| `get_motion_effect` | One effect by `id`: install snippet, usage, how it works and, unless `includeSource` is false, the full Swift source. |

## Set up

Clone the repository (or download just `server.mjs`), then register the server.

**Claude Code**

```sh
claude mcp add swiftui-motion -- node /path/to/SwiftUI-Motion-Library/mcp/server.mjs
```

**Claude Desktop, Cursor, VS Code and other clients** use the same JSON shape (`claude_desktop_config.json`, `.cursor/mcp.json`, …):

```json
{
  "mcpServers": {
    "swiftui-motion": {
      "command": "node",
      "args": ["/path/to/SwiftUI-Motion-Library/mcp/server.mjs"]
    }
  }
}
```

Then ask for something like "add a hold-to-confirm delete button" or "show a loading spinner that turns into a checkmark".

## Other ways for AI tools to use the library

- [`llms.txt`](../llms.txt) and [`llms-full.txt`](../llms-full.txt): paste or point your assistant at them.
- [`skills/swiftui-motion`](../skills/swiftui-motion): an Agent Skill. Copy it to `~/.claude/skills/` (or your project's `.claude/skills/`).
- [`.cursor/rules/swiftui-motion.mdc`](../.cursor/rules/swiftui-motion.mdc): a Cursor rule. Copy it to your project's `.cursor/rules/`.
- [`Docs/motion-catalog.json`](../Docs/motion-catalog.json): everything as JSON.

All of these are generated from the catalog by `Scripts/generate-docs.sh`.
