#!/usr/bin/env node
// MCP server for SwiftUI Motion Library: lets any MCP client (Claude Code,
// Claude Desktop, Cursor, VS Code…) search the effects and fetch their usage,
// implementation notes and full source.
//
// Zero dependencies: speaks MCP's stdio transport (newline-delimited JSON-RPC
// 2.0) directly. Reads Docs/motion-catalog.json from this repository when run
// from a checkout, otherwise downloads it from GitHub.
//
//   node mcp/server.mjs

import { readFile } from "node:fs/promises";
import { createInterface } from "node:readline";
import { fileURLToPath } from "node:url";

const CATALOG_URL =
  "https://raw.githubusercontent.com/BigTsung/SwiftUI-Motion-Library/main/Docs/motion-catalog.json";
const LOCAL_CATALOG = fileURLToPath(new URL("../Docs/motion-catalog.json", import.meta.url));
const SERVER_INFO = { name: "swiftui-motion", version: "0.2.0" };
const SUPPORTED_PROTOCOLS = ["2025-06-18", "2025-03-26", "2024-11-05"];

let catalogPromise;
function loadCatalog() {
  catalogPromise ??= (async () => {
    try {
      return JSON.parse(await readFile(process.env.MOTION_CATALOG ?? LOCAL_CATALOG, "utf8"));
    } catch {
      const response = await fetch(CATALOG_URL);
      if (!response.ok) throw new Error(`Couldn't download the catalog (${response.status})`);
      return response.json();
    }
  })();
  // Retry on the next call if loading failed.
  catalogPromise.catch(() => (catalogPromise = undefined));
  return catalogPromise;
}

// MARK: - Tools

const TOOLS = [
  {
    name: "list_motion_effects",
    title: "List SwiftUI motion effects",
    description:
      "Lists SwiftUI Motion Library effects (animated text, button interactions, card transitions, loaders, confetti, backgrounds, particles, 3D) with their one-line API. Filter by component, trigger or a search query. Call get_motion_effect for usage and source.",
    inputSchema: {
      type: "object",
      properties: {
        query: { type: "string", description: "Words to match in the name, summary or API, e.g. 'loading', 'card', 'confetti'." },
        component: {
          type: "string",
          enum: ["text", "button", "card", "shape", "background", "number", "particle"],
          description: "Only effects for this kind of UI element.",
        },
        trigger: {
          type: "string",
          enum: ["appear", "tap", "press", "drag", "hover", "scroll", "change", "loop"],
          description: "Only effects that play on this trigger.",
        },
      },
      additionalProperties: false,
    },
    annotations: { readOnlyHint: true, openWorldHint: false },
  },
  {
    name: "get_motion_effect",
    title: "Get a SwiftUI motion effect",
    description:
      "Returns one effect's install snippet, usage code, implementation notes and (optionally) full Swift source, ready to drop into a SwiftUI project.",
    inputSchema: {
      type: "object",
      properties: {
        id: { type: "string", description: "Effect id from list_motion_effects, e.g. 'shimmer' or 'hold-to-confirm'." },
        includeSource: { type: "boolean", description: "Include the full Swift source of the effect. Defaults to true." },
      },
      required: ["id"],
      additionalProperties: false,
    },
    annotations: { readOnlyHint: true, openWorldHint: false },
  },
];

function matches(effect, { query, component, trigger }) {
  if (component && effect.component !== component) return false;
  if (trigger && !effect.triggers.includes(trigger)) return false;
  if (!query) return true;
  const haystack = `${effect.id} ${effect.name} ${effect.summary} ${effect.api} ${effect.componentTitle}`.toLowerCase();
  return query
    .toLowerCase()
    .split(/\s+/)
    .filter(Boolean)
    // Crude stemming so "loading" finds "loaders" and "cards" finds "card".
    .map((word) => (word.length > 4 ? word.replace(/(ing|ers|er|es|s)$/, "") : word))
    .some((word) => haystack.includes(word));
}

async function listEffects(args = {}) {
  const catalog = await loadCatalog();
  const found = catalog.effects.filter((effect) => matches(effect, args));
  if (found.length === 0) {
    return `No effects match. Components: text, button, card, shape, background, number, particle. ${catalog.effects.length} effects in total; call again without filters to see them all.`;
  }
  const lines = found.map((effect) => {
    const requirement = effect.requirement === "iOS 17+" ? "" : ` [${effect.requirement}]`;
    return `- ${effect.id}: ${effect.name}${requirement}, \`${effect.api}\` (${effect.componentTitle}; ${effect.triggers.join(", ")}). ${effect.summary}`;
  });
  return `${found.length} effect(s):\n${lines.join("\n")}\n\nCall get_motion_effect with an id for usage and source.`;
}

async function getEffect({ id, includeSource = true } = {}) {
  const catalog = await loadCatalog();
  const effect = catalog.effects.find((candidate) => candidate.id === id);
  if (!effect) {
    const ids = catalog.effects.map((candidate) => candidate.id).join(", ");
    throw new ToolError(`Unknown effect id "${id}". Valid ids: ${ids}`);
  }
  const parts = [
    `# ${effect.name} (${effect.id})`,
    effect.summary,
    `API: \`${effect.api}\`\nTrigger: ${effect.triggers.join(", ")}\nRequires: ${effect.platforms}\nSource: ${effect.sourceURL}\nPreview: ${effect.gifURL}`,
    `## Install\n\n${catalog.install}`,
    `## Usage\n\n\`\`\`swift\nimport MotionLibrary\n\n${effect.usage}\n\`\`\``,
    `## How it works\n\n${effect.prompt}`,
  ];
  if (includeSource) {
    parts.push(`## Source (${effect.sourceFile})\n\nTo use it without the package, copy this file into the project.\n\n\`\`\`swift\n${effect.source}\n\`\`\``);
  }
  return parts.join("\n\n");
}

class ToolError extends Error {}

// MARK: - JSON-RPC over stdio

function send(message) {
  process.stdout.write(`${JSON.stringify({ jsonrpc: "2.0", ...message })}\n`);
}

async function handle(request) {
  const { id, method, params } = request;
  const isNotification = id === undefined || id === null;

  switch (method) {
    case "initialize": {
      const requested = params?.protocolVersion;
      return {
        protocolVersion: SUPPORTED_PROTOCOLS.includes(requested) ? requested : SUPPORTED_PROTOCOLS[0],
        capabilities: { tools: {} },
        serverInfo: SERVER_INFO,
        instructions:
          "Use these tools when a SwiftUI project needs animation or motion: list_motion_effects to find a ready-made effect, then get_motion_effect for the code. Prefer the library API over hand-writing the animation.",
      };
    }
    case "ping":
      return {};
    case "tools/list":
      return { tools: TOOLS };
    case "tools/call": {
      const name = params?.name;
      const args = params?.arguments ?? {};
      try {
        let text;
        if (name === "list_motion_effects") text = await listEffects(args);
        else if (name === "get_motion_effect") text = await getEffect(args);
        else throw Object.assign(new Error(`Unknown tool: ${name}`), { code: -32602 });
        return { content: [{ type: "text", text }] };
      } catch (error) {
        if (error.code) throw error;
        // Tool failures are reported in the result so the model can recover.
        return { content: [{ type: "text", text: error.message }], isError: true };
      }
    }
    default:
      if (isNotification) return undefined; // e.g. notifications/initialized
      throw Object.assign(new Error(`Method not found: ${method}`), { code: -32601 });
  }
}

const lines = createInterface({ input: process.stdin });
lines.on("line", async (line) => {
  if (!line.trim()) return;
  let request;
  try {
    request = JSON.parse(line);
  } catch {
    send({ id: null, error: { code: -32700, message: "Parse error" } });
    return;
  }
  const isNotification = request.id === undefined || request.id === null;
  try {
    const result = await handle(request);
    if (!isNotification) send({ id: request.id, result });
  } catch (error) {
    if (!isNotification) send({ id: request.id, error: { code: error.code ?? -32603, message: error.message } });
  }
});
