# 0tx Cursor plugin

Cursor (and Grok Bot) plugin for [0tx](https://0tx.app) ("ZeroTax"), a personal tax accounting ledger.

This package does not host 0tx. It points agents at the remote MCP server:

```json
{
  "mcpServers": {
    "0tx": {
      "type": "http",
      "url": "https://0tx.app/mcp"
    }
  }
}
```

Unauthenticated requests to that URL return **401**. That is expected until you sign in. Auth lives on the 0tx server, not in this repo.

**Not submitted** to the Cursor Marketplace yet. Test locally first (below), then publish later at [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish).

## What's in the plugin

| Path | Purpose |
| --- | --- |
| `.cursor-plugin/plugin.json` | Manifest |
| `mcp.json` | Remote HTTP MCP |
| `skills/0tx/SKILL.md` | When/how agents should use 0tx |
| `assets/logo.svg` | Icon |

## Test before marketplace publication

### 1. Cursor — local plugin (full install)

1. Clone this repo (or copy the folder) to `~/.cursor/plugins/local/0tx`
2. In Cursor: **Developer: Reload Window**
3. Open **Customize** (or Settings → Plugins) and confirm **0tx** is listed with its MCP server and skill
4. Connect / sign in if Cursor shows a connect card
5. Ask the agent something that needs the ledger (e.g. list accounts)

If a marketplace plugin named `0tx` is already installed, that listing wins over the local copy.

### 2. Cursor — MCP only (no plugin folder)

Add the same server in `~/.cursor/mcp.json` or **Customize → MCP**:

```json
{
  "mcpServers": {
    "0tx": {
      "type": "http",
      "url": "https://0tx.app/mcp"
    }
  }
}
```

This tests the MCP endpoint without the skill/manifest.

### 3. Grok Bot — custom connector

Grok Bot only shows **catalog** plugins in Plugins until this is published. Before that, add `https://0tx.app/mcp` as a custom MCP connector (same URL). Skills from this repo will not load in Grok Bot until the marketplace listing exists.

## Author

Petrus Theron — [0tx.app](https://0tx.app) · [github.com/theronic/0tx-cursor-plugin](https://github.com/theronic/0tx-cursor-plugin)
