---
name: 0tx-review-period
description: Use this when the user wants to review a month, quarter, tax year or other date range in a 0tx ledger - income and expense summaries, the largest accounts, activity per account, finding uncategorised or suspicious entries, or preparing figures for a tax period. Read-only unless the user then asks for corrections.
---

# Reviewing a period in 0tx

A review only reads. It works on any ledger whose `assistant_access` is `"view"` or `"edit"`.

## Set the scope

1. `list-ledgers`; agree the ledger with the user if there is more than one.
2. Agree the dates. A range includes its start and excludes its end: March 2026 is `2026-03-01` to `2026-04-01`; a tax year from 1 March 2025 to 28 February 2026 is `2025-03-01` to `2026-03-01`. If the user says "this tax year" and the year's start month is not known, ask.
3. `chart-of-accounts` (depth 1 or 2) to see the top-level accounts and their types and units.

## Steps

1. **Overall picture**: `ledger-summary-between` for the range gives debit and credit totals per unit and the top income and expense accounts.
2. **Largest accounts**: `rank-accounts-between`, with `account-types` to look at expense or revenue accounts only.
3. **Detail under one account**: `account-activity-between` with that account's UUID gives direct, descendant and total debit and credit sums per unit for every sub-account.
4. **Volume**: `count-lines-by-account` and `count-journal-entries` show where the entries are before you page through them.
5. **Entries**: `account-journal-entry-lines` for one account's lines; `search-journal-entries` for text. Page through large results and say how many there are in total.
6. **Things to check**: accounts of type import hold entries that have not been categorised yet; look also for entries with no description, the same amount on the same date twice, and lines in an account whose type does not fit the description.

## Reporting

- Sums come back as `[debits, credits]` in minor units per unit. The balance for display is debits minus credits, so a negative result is a credit balance. Convert to major units for the user and name the unit.
- Keep units separate. Do not add amounts in different currencies or convert between them unless the user gives a rate.
- State the ledger, the exact date range and whether text search was `current` or `catching-up`.
- Give figures from tool results only. If a number was not returned by a tool, say that it is not available instead of estimating it.
- This is bookkeeping, not tax advice. Report what the ledger holds and leave the tax treatment to the user or their accountant.

## If the review finds something to fix

List the proposed corrections with entry dates, descriptions and amounts, and ask the user before changing anything. Changes need `"edit"` access on the ledger; if it is `"view"`, the ledger's owner can allow changes under "Connected assistants" on the 0tx AI page (https://0tx.app/ai-accountant).
