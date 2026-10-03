---
name: 0tx-post-entries
description: Use this when the user wants to record, import, correct, recategorise or delete journal entries in a 0tx ledger - posting a transaction, splitting it across accounts, fixing a wrong amount or account, moving lines to another account, deleting entries or an empty account, or staging a batch of changes for review before committing.
---

# Posting and correcting entries in 0tx

These tools record bookkeeping in a ledger. They never move money, pay anyone or place a trade.

## Before any change

1. `list-ledgers`, and check that the ledger's `assistant_access` is `"edit"`. If it is `"view"`, stop and tell the user that the ledger's owner can allow changes under "Connected assistants" on the 0tx AI page (https://0tx.app/ai-accountant).
2. Find the accounts with `search-accounts` or `chart-of-accounts` and keep their UUIDs. Prefer accounts that exist over creating new ones. Check that each account's units match the amount you will post to it.
3. Look for the entry first with `search-journal-entries` (same date range, a word from the description) so that you do not post a duplicate.
4. Show the user the entry as you will send it and wait for a yes: date, description, and each line with account name, debit or credit, and amount in major units.

## Shape of an entry

```json
{
  "ledger_id": "<ledger_id from list-ledgers>",
  "entries": [
    {
      "date": "2026-03-14",
      "description": "Lunch with client",
      "lines": [
        { "type": "debit",  "account": "<expense account UUID>", "amount": ["ZAR", 12500] },
        { "type": "credit", "account": "<bank account UUID>",    "amount": ["ZAR", 12500] }
      ]
    }
  ]
}
```

- `type` is `dr`, `debit`, `cr` or `credit`. Direction comes from `type`; `amount_minor` is not signed.
- `amount` is `[units, amount_minor]` with an integer: R125.00 is `["ZAR", 12500]`.
- Debits equal credits in every unit. An entry in two units balances in each of them separately.
- A split is one entry with more than two lines.
- `account` is a UUID. Names and paths are rejected.

## Which tool

| Task | Tool | Notes |
| --- | --- | --- |
| Add new entries | `post_entries` | Creates only. Supply your own `uuid` on entries when a lost response would otherwise leave you unsure. |
| Replace an entry (date, description, lines) | `edit_entries` | The whole entry is replaced by the payload you send, so send every line, not only the changed one. Read the entry first. |
| Move lines to another account | `transfer_lines` | A recategorisation inside the ledger, not a money transfer. Each move names `line_uuid`, `from` and `to`. |
| Remove entries | `delete_entries` | Deleted entries are gone. Confirm the list of entries with the user first. |
| Remove an empty account | `delete_account` | Refused when the account or any sub-account has ever had lines, and for the ledger's root. |

Confirm with the user before every `edit_entries`, `delete_entries`, `delete_account` and `transfer_lines` call, naming what will change.

## Staging a batch for review

For more than a few changes, or when the user wants to check the work first, stage instead of writing directly:

1. `create-change-set` with the ledger and an account UUID. Keep the conversation UUID it returns.
2. `stage-ledger-plan` with the draft account creations, empty-account deletions and entry plans. Nothing in the ledger changes.
3. `review-change-set`. Show the user the summary. Keep `reviewCommit` and `reviewHash`.
4. After the user says yes, `commit-change-set` with both values unchanged. If the drafts changed after the review, review again.
5. `discard-change-set` drops the staged drafts and leaves the ledger as it was.

## After the call

- A change happened only when the result reports `status` `committed`. Report the entry UUIDs or counts from the result.
- `head-conflict`: another change landed first. Read the affected entries again, then decide with the user whether to repeat.
- `operation-outcome-unknown`: the outcome is not known. Do not repeat blindly. Read the entries (by the UUIDs you supplied, or by search) to see whether the change is there. Repeating an identical `post_entries` call with the same UUIDs answers a conflict if the first one committed.
- `not-found` on edit or delete: the entry does not exist or was already deleted. Nothing was written.
- `forbidden` with reason `agent-view-only`, or `not-found` with reason `agent-ledger-access`: the owner has not allowed this. Tell the user where to change it (Connected assistants on the 0tx AI page) and stop.

Never tell the user an entry was posted, edited, moved or deleted without a committed result for that call.
