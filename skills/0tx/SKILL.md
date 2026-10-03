---
name: 0tx
description: Use this when the user asks about their 0tx (ZeroTax) ledger - listing ledgers, reading the chart of accounts, finding accounts, searching or counting journal entries, or asking what a 0tx tool refusal means. Covers how to call the 0tx MCP tools - list-ledgers first, ledger_id on every call, amounts in minor units, date ranges.
---

# 0tx

0tx ("ZeroTax", https://0tx.app) is a multi-currency double-entry general ledger for personal and small-business bookkeeping and tax. The `0tx` MCP server gives access to the ledgers the signed-in person chose for this connection. The tools record bookkeeping only. Nothing they do moves money, pays anyone or places a trade.

## Order of work

1. Call `list-ledgers` first. Each row has a `ledger_id` and an `assistant_access` of `"view"` or `"edit"`. The list is complete: a ledger that is not in it has not been given to this connection.
2. If there is more than one ledger and the user has not said which one, ask.
3. Pass that `ledger_id` to every other tool. Use the `ledger_id` value itself; `entry_points` in a row explain why a ledger is reachable and are not ledger ids.
4. Read before you write. Find accounts and existing entries before proposing any change.

## Rules that hold for every tool

- **Accounts are named by UUID**, never by name or path. Get UUIDs from `chart-of-accounts` or `search-accounts`.
- **Amounts are integers in minor units**, written `[units, amount_minor]`. `["ZAR", 12500]` is R125.00; `["USD", 12500]` is USD 125.00. Convert to major units only when showing amounts to the user, and keep each unit separate: do not add ZAR to USD.
- **Dates are `YYYY-MM-DD`.** A date range includes its start and excludes its end. All of 2025 is start `2025-01-01`, end `2026-01-01`. A tax or financial year that runs March to February is start `2025-03-01`, end `2026-03-01`.
- **Every entry balances per unit**: total debits equal total credits in each unit.
- **Parameter names differ between tools** (`start-date` and `end-date` in some, `start-date-incl` and `end-date-excl` in others; `account-uuid` in some, `account_uuid` in others). Use the names in each tool's own schema.
- Use only the tool names the server lists. Do not guess at tools that are not there.

## Reading tools

| Need | Tool |
| --- | --- |
| Which ledgers can I use | `list-ledgers` |
| The account tree (optional `depth`, default 1) | `chart-of-accounts` |
| Find an account by name or path | `search-accounts` |
| Totals and top income and expense accounts for a period | `ledger-summary-between` |
| Accounts ranked by activity for a period | `rank-accounts-between` |
| Debit and credit sums per account, as a tree | `account-activity-between` |
| How many journal lines each account has in a period | `count-lines-by-account` |
| The lines of one account, paged with `offset` and `limit` | `account-journal-entry-lines` |
| Entries matching text, account and dates, paged with `cursor` | `search-journal-entries` |
| How many entries match | `count-journal-entries` |
| What a staged change set contains | `review-change-set` |

Text search is eventually consistent. When a result's `search_index.status` is `catching-up`, tell the user that recent entries may be missing from the result.

For long lists, page through results instead of asking for everything at once, and report `total_count` so the user knows how much there is.

## Changing a ledger

Changes need `assistant_access` of `"edit"` on that ledger. The changing tools are `post_entries`, `edit_entries`, `delete_entries`, `delete_account`, `transfer_lines`, `create-change-set`, `stage-ledger-plan`, `commit-change-set` and `discard-change-set`. Before calling `edit_entries`, `delete_entries`, `delete_account`, `transfer_lines` or `commit-change-set`, show the user exactly what will change and wait for a clear yes. `transfer_lines` moves journal lines from one account to another inside the ledger (a recategorisation); it does not transfer money.

Say that a change was made only when the tool result reports `status` `committed`. An error result means the change was not confirmed; read the ledger again to see its state before trying again.

## When a call is refused

- **`not-found` with reason `agent-ledger-access`**: the ledger was not given to this connection (or does not exist). Tell the user that the ledger's owner chooses each assistant's ledgers under "Connected assistants" on the 0tx AI page, https://0tx.app/ai-accountant.
- **`forbidden` with reason `agent-view-only`**: the owner allowed viewing only. Tell the user that the owner can allow changes in the same place. Do not retry and do not try another tool to make the same change.
- **`list-ledgers` returns nothing**: no ledger has been given to this connection yet. Same place to fix it.
- **401 before sign-in**: expected. The user signs in with their 0tx account in the browser window the client opens, and chooses the ledgers there.

A connection never has more access than the account of the person who approved it.
