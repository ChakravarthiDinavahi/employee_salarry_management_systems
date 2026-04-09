# Salary Management Tool — Planning & Architecture

## Overview

This application is a Rails 7 salary management system backed by **SQLite** (database files under `storage/`). There is no separate database server to run locally or in small deployments. The UI uses **Tailwind CSS** for styling and **Hotwire** (Turbo + Stimulus) for interactivity without building a separate client-side SPA.

---

## Why Hotwire / Turbo for the UI

We use **Hotwire**—primarily **Turbo Drive** and **Turbo Frames**—so the browser stays fast and simple while the product still feels responsive.

### Minimizing JavaScript overhead

- **Server-rendered HTML remains the source of truth.** Forms, lists, and detail pages are ordinary Rails views. The server does the heavy lifting (validation, authorization, rendering), so we avoid shipping large JavaScript bundles, complex state machines, and duplicate business logic in the browser.
- **Turbo replaces full-page reloads with fast navigation** by swapping only the `<body>` (or targeted frames) while preserving scroll and form state where configured. Users get snappier transitions without maintaining a React/Vue layer for every screen.
- **Stimulus is used sparingly** for small, explicit behaviors (e.g. toggles, keyboard shortcuts) that do not belong in the server round-trip. That keeps the JS footprint small compared to a full SPA.

### Staying interactive

- **Turbo Streams** can append, replace, or remove DOM fragments after server actions—ideal for live updates without full-page reloads when we add richer workflows later.
- **Progressive enhancement** means core CRUD works without JavaScript; Turbo layers on better UX when available.

### Trade-off

- **Real-time collaboration** (e.g. live cursors across users) would need Action Cable or a dedicated channel; Hotwire is optimized for **request/response + targeted updates**, not a game engine. For HR dashboards and salary workflows, that is a good fit.

---

## Indexing Strategy for 10,000+ Records (HR Insights)

SQLite (like any relational engine) may **scan the whole table** when no suitable index exists. At **10,000+ rows**, full scans can be acceptable for rare queries, but **HR Manager “insights”** (filters by country, role, salary bands, and comparisons) will be repeated and should stay indexed.

### Composite index: `[:country, :job_title]`

**Purpose:** Queries that filter or group by **country and job title** together—e.g. “average salary by role in India,” “headcount by title in France,” or “list all engineers in the US.”

**Why this order:** The composite index supports:

- Equality on `country` plus `job_title` (classic reporting slice).
- Prefix use: `WHERE country = ?` can use the leftmost column of the index; `WHERE job_title = ?` alone **does not** use the composite index efficiently unless we add a separate index on `job_title` (add if we see frequent global title-only searches).

**Operational note:** If we later need **only** `job_title` across all countries often, consider a dedicated index on `job_title` or a precomputed summary table for heavy aggregates.

### Index on `salary`

**Purpose:** Range and ordering on compensation—e.g. “top earners,” “employees between $X and $Y,” sort by salary on a filtered list.

**Why:** B-tree indexes (Rails default) support **`<`, `>`, `BETWEEN`, and `ORDER BY salary`** efficiently when the query planner can combine this index with other predicates (e.g. after filtering by `country` via the composite index, depending on statistics and query shape).

### General practices at this scale

- **Keep insights in SQL** (`GROUP BY`, `AVG`, `COUNT`) with `EXPLAIN QUERY PLAN` on the slow paths; add indexes only where proven.
- **Avoid `SELECT *`** on large lists; paginate (e.g. `LIMIT`/`OFFSET` or keyset pagination) for UI tables.
- **Run `ANALYZE`** after bulk loads so SQLite’s query planner has up-to-date statistics.

---

## Stack Summary

| Layer        | Choice              | Role |
|-------------|---------------------|------|
| Framework   | Rails 7             | MVC, CRUD, conventions |
| Database    | SQLite              | Relational data, indexes, aggregates (single file per environment) |
| CSS         | Tailwind (via tailwindcss-rails) | Utility-first styling |
| Interactivity | Turbo + Stimulus  | Fast navigation, minimal JS |

This document should evolve as we add reporting endpoints, caching, and background jobs for heavy exports.
