# 0tx plugin

Connects an AI assistant to [0tx](https://0tx.app) ("ZeroTax"), a multi-currency double-entry general ledger for personal and small-business bookkeeping and tax.

With the plugin installed, your assistant can:

- find your ledgers, accounts and journal entries, and search entries by description, account and date;
- summarise what moved through your accounts between two dates;
- post balanced entries, split across accounts and currencies, and move lines to the right account;
- stage a batch of changes for you to review before any of it is committed.

The tools record bookkeeping only. Nothing they do moves money, pays anyone or places a trade.

You need a 0tx account with at least one ledger. Plans are described at https://0tx.app/pricing.

## What it installs

| Part | Files | What it does |
| --- | --- | --- |
| One MCP server entry, named `0tx` | `mcp.json`, `.mcp.json` (same content) | Points the client at `https://api.0tx.app/mcp`. The server runs at 0tx; this repository holds no server code. |
| Skill `0tx` | `skills/0tx/SKILL.md` | How to find ledgers and read them, and what a refusal means. |
| Skill `0tx-post-entries` | `skills/0tx-post-entries/SKILL.md` | How to post and correct entries, and how to stage a batch for review. |
| Skill `0tx-review-period` | `skills/0tx-review-period/SKILL.md` | How to review a month, quarter or tax year. |

There are no hooks, commands, scripts that run on install, or binaries.

The MCP entry:

```json
{
  "mcpServers": {
    "0tx": {
      "type": "http",
      "url": "https://api.0tx.app/mcp"
    }
  }
}
```

## Install

### Cursor and Grok Bot

Open the marketplace in the app, search for **0tx** and install it. Then open the plugin's MCP server and choose **Connect**.

To use the server without the plugin, add the MCP entry above to `~/.cursor/mcp.json` (Cursor), or add `https://api.0tx.app/mcp` as a custom MCP connector (Grok Bot).

### Grok Build

In Grok Build, open `/plugins`, search for **0tx** and install it. Or from a shell:

```sh
grok plugin install theronic/0tx-cursor-plugin
grok plugin enable 0tx
```

Then open `/mcps`, select `0tx` and press `i` to sign in. Without the plugin: `grok mcp add --transport http 0tx https://api.0tx.app/mcp`.

### Claude Code

```sh
claude plugin marketplace add theronic/0tx-cursor-plugin
claude plugin install 0tx@0tx
```

Then run `/mcp` in a session, select `0tx` and sign in. Without the plugin: `claude mcp add --transport http 0tx https://api.0tx.app/mcp`.

### ChatGPT and Codex

Install **0tx** from the plugin directory and connect it when asked. Without the plugin, in Codex: `codex mcp add 0tx --url https://api.0tx.app/mcp`.

## First run: sign in and choose ledgers

1. The first time the client calls the server it opens a 0tx page in your browser.
2. Sign in with your 0tx account.
3. The approval page lists your ledgers. For each one choose **No access**, **View**, or **View and edit**, then approve.
4. Back in the client, ask "Which 0tx ledgers can you use?". The assistant calls `list-ledgers` and shows the ledgers you chose.

The connected client is an assistant of yours. It never has more access than your own account, and it stays signed in until you remove it. To change what it may use, to give it a ledger you created later, or to disconnect it, open **Connected assistants** on https://0tx.app/ai-accountant.

## Tools

20 tools. `list-ledgers` finds the ledgers; every other tool takes a `ledger_id` from it.

| Read only | Changes the ledger |
| --- | --- |
| `list-ledgers`, `chart-of-accounts`, `search-accounts`, `ledger-summary-between`, `rank-accounts-between`, `account-activity-between`, `count-lines-by-account`, `account-journal-entry-lines`, `search-journal-entries`, `count-journal-entries`, `review-change-set` | `post_entries`, `edit_entries`, `delete_entries`, `delete_account`, `transfer_lines`, `create-change-set`, `stage-ledger-plan`, `commit-change-set`, `discard-change-set` |

`transfer_lines` moves journal lines from one account to another inside a ledger (a recategorisation). It does not transfer money.

Amounts are integers in minor units written `[units, amount_minor]`: `["ZAR", 12500]` is R125.00. Dates are `YYYY-MM-DD`; a date range includes its start and excludes its end. Every entry balances per unit. Accounts are named by UUID.

More detail: https://0tx.app/guides/mcp-and-api-discovery

## Network endpoints and credentials

The plugin makes the client call these hosts and no others:

| Endpoint | Purpose |
| --- | --- |
| `https://api.0tx.app/mcp` | The MCP server. Streamable HTTP, stateless, JSON responses. |
| `https://api.0tx.app/.well-known/oauth-protected-resource` and `/.well-known/oauth-protected-resource/mcp` | OAuth protected-resource metadata. |
| `https://0tx.app/.well-known/oauth-authorization-server` | OAuth authorization-server metadata. Issuer `https://0tx.app`. |
| `https://0tx.app/oauth/register` | Dynamic client registration. |
| `https://0tx.app/oauth/authorize` | Sign-in and the per-ledger approval page, in your browser. |
| `https://0tx.app/oauth/token`, `https://0tx.app/oauth/revoke` | Token exchange, refresh and revocation. |

Credentials: a 0tx account. The client signs in with OAuth 2.1 (authorization code with PKCE, S256) and asks for the scope `mcp:tools`. The client stores the tokens it receives; access tokens last a year and are refreshed until you remove the connection. This repository contains no API key, token, client secret or other credential, and the plugin reads no environment variables or local files.

## Data handling

The assistant sees what the tools return for the ledgers you chose: ledger and account names, journal entry dates, descriptions, notes and amounts. 0tx stores the entries the assistant posts in your ledger, as it does for entries you post yourself; what your AI client does with what it reads is governed by that client's own terms.

Privacy policy: https://0tx.app/privacy [OWNER: publish the privacy policy at this address, or replace the address here and in `.codex-plugin/plugin.json`]

Terms of service: https://0tx.app/terms [OWNER: publish the terms at this address, or replace the address here and in `.codex-plugin/plugin.json`]

## Troubleshooting

- **401 before sign-in.** Expected. The server answers 401 with a pointer to its OAuth metadata until the client has signed in. Use the client's connect or sign-in action for the `0tx` server.
- **A ledger is missing, or "Ledger not found".** The assistant has not been given that ledger. Open Connected assistants on https://0tx.app/ai-accountant and choose View or View and edit for it. Ledgers created after you connected are not given to an assistant until you choose them there.
- **A change is refused as view-only.** The ledger is set to View for this assistant. Change it to View and edit in the same place.
- **The client refuses the server address.** Use `https://api.0tx.app/mcp` exactly. Clients compare the address with the server's resource metadata, and other addresses do not match.
- **The assistant lost access.** It was removed under Connected assistants, or its access was changed. Connect again from the client.

## Development

```sh
sh scripts/check.sh             # manifests parse, versions agree, MCP files identical
sh scripts/build-openai-zip.sh  # writes dist/0tx-openai-plugin.zip
```

One version number is kept in `.cursor-plugin/plugin.json`, `.grok-plugin/plugin.json`, `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`. Change all four together and add a `CHANGELOG.md` entry; directories pick up a release from the version number.

## Licence

MIT. See [LICENSE](LICENSE). The licence covers this repository. Use of the 0tx service is governed by the 0tx terms.

## Support

hello@0tx.app [OWNER: confirm the support address, and the support page https://0tx.app/support named in `.codex-plugin/plugin.json`]

Author: Petrus Theron, https://0tx.app
