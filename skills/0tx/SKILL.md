---
name: 0tx
description: Use this when working with 0tx (ZeroTax) — personal tax accounting, ledgers, bank/crypto/stock imports, deductions, or 0tx.app. Connects via the 0tx MCP.
---

# 0tx

0tx ("ZeroTax") is a personal tax accounting ledger at [0tx.app](https://0tx.app). Agents reach it through the remote MCP server at `https://0tx.app/mcp`.

## When to use

- Looking up accounts, balances, or transactions in 0tx
- Importing or reconciling bank, property, stock, or crypto activity for tax
- Calculating tax or reviewing deductions in the 0tx ledger
- Sharing or inspecting chart-of-accounts access with an accountant or collaborator

## How to work

1. Use the **0tx** MCP connector. If it is not connected, ask the user to sign in. An unauthenticated call returning 401 is expected until they complete auth.
2. Discover and call the tools the server actually exposes after connect. Do not invent tool names or pretend a ledger action succeeded without a tool result.
3. Prefer the MCP tools over scraping 0tx.app.
4. Never put API keys or session tokens in the plugin repo, chat logs you control, or committed files.

## Auth

Auth is owned by `https://0tx.app/mcp` (OAuth / connect card). This plugin only points Cursor at that URL.
