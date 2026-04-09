# Employee Salary Management System

Rails 7 app for employee records and salary analytics: **Hotwire** (Turbo) server-rendered UI, SQLite, Tailwind, **Pagy**, **Chartkick**, and SQL aggregates via `SalaryStatsQuery`.

It also ships a **`/api/v1/*` JSON API** and a **Vite + React** SPA in `frontend/` for the same domain over HTTP JSON.

## Quick start

**Prerequisites:** Ruby (see `.ruby-version`), Bundler, SQLite, **Node.js** (for the React app).

```bash
bundle install
npm install --prefix frontend
bin/rails db:prepare
```

Optional demo data (~10k rows):

```bash
bin/rails db:seed
```

Start everything (Rails, Tailwind watcher, Vite):

```bash
bin/dev
```

| What | URL |
|------|-----|
| **React SPA** (use this for the API-driven UI) | http://localhost:5173 |
| **Rails** (HTML UI + JSON API) | http://localhost:3000 |

The Vite dev server **proxies** `/api` to Rails on port 3000, so the SPA calls `/api/v1/...` without CORS issues in local development.

## Development without `bin/dev`

Run in **two terminals** from the project root:

```bash
# Terminal 1 — API + Hotwire UI
bin/rails server -p 3000
```

```bash
# Terminal 2 — React
npm run dev --prefix frontend
```

Still open **http://localhost:5173** for the React client. If you only need the Rails HTML app, use **http://localhost:3000** (e.g. employees and insights as server-rendered pages).

`bin/dev` is defined in **`Procfile.dev`**: Rails on 3000, Tailwind watch, and `npm run dev` in `frontend/`.

## JSON API and React SPA

- **Employees:** `GET/POST /api/v1/employees`, `GET/PATCH/DELETE /api/v1/employees/:id` (JSON). Query params include `q`, `page`, `limit`.
- **Insights:** `GET /api/v1/salary_insights` — aggregates for charts/tables.

**Production-style split:** build the SPA with `npm run build --prefix frontend` (output in `frontend/dist`). Set **`VITE_API_BASE_URL`** to your Rails base URL when the static files are served separately. Configure Rails **`FRONTEND_ORIGIN`** (and CORS) so the browser may call the API from that origin.

## Handling the ~10,000 record constraint

This app is designed so full-table work stays fast as data grows:

1. **Indexing** — Composite index on `[country, job_title]` and an index on `salary` for reporting. See `db/schema.rb`.
2. **Pagy** — List endpoints paginate (e.g. 25 rows per page); the browser never loads all employees at once.
3. **Bulk seeds** — `db/seeds.rb` uses **`activerecord-import`** in batches inside a transaction instead of thousands of individual inserts.

## Why Hotwire for the main UI?

We use **Hotwire** (Turbo + Stimulus) for the default Rails UI because forms, tables, and insights stay in views and controllers without maintaining a parallel API contract for every change. The **React SPA** in `frontend/` reuses the same behavior through the JSON API when you want a client-heavy or API-first workflow.

## Code style (RuboCop)

Linting uses **`rubocop-rails-omakase`**. See the **[Ruby Style Guide](https://rubystyle.guide/)**.

```bash
bin/rubocop
bundle exec rubocop -A   # auto-correct safe cops
```

Configuration: **`.rubocop.yml`**.

## Schema annotations (Annotate)

After migrations, refresh model schema comments:

```bash
bundle exec annotate
```

## Seed data (10k employees)

Loads name lists from `lib/data/*.txt` and bulk-inserts 10,000 employees. Skip with `SKIP_EMPLOYEE_SEED=1` for an empty database.

```bash
bin/rails db:seed
```

## Tests

```bash
bundle exec rspec
```

## Insights (Hotwire UI)

From the Rails UI, open **Salary insights**, or visit **`/insights`**. Charts use **Chartkick** with data from `SalaryStatsQuery` (SQL aggregations).
