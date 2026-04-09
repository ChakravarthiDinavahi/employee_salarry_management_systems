# Employee Salary Management System

Rails 7 HR dashboard for employees and salary insights: server-rendered UI (Hotwire), SQLite, Tailwind CSS, Pagy pagination, and Chartkick visualizations backed by aggregate SQL via a query object.

## Handling the ~10,000 record constraint

This app is designed so “full table” operations stay fast and predictable as data grows into the thousands of rows:

1. **Database indexing** — The `employees` table has a composite index on `[country, job_title]` for grouped reporting and filtering, and an index on `salary` for range/sort queries used in insights. See `db/schema.rb` and the original migration.

2. **Pagy (server-side pagination)** — The employee list never loads all rows at once. The index action uses **Pagy** with a fixed page size (25 rows), so the browser and Rails only materialize one page per request.

3. **Bulk imports for seeds** — `db/seeds.rb` inserts **10,000** demo rows using **`activerecord-import`** in batched inserts inside a single transaction, instead of thousands of `Employee.create!` calls. That keeps seed time low and reflects how you would backfill large datasets in production.

Together: indexes keep analytics queries selective, Pagy keeps list endpoints bounded, and bulk import keeps one-off large loads efficient.

## Why Hotwire instead of React?

We use **Hotwire** (Turbo + Stimulus) rather than a separate React (or similar) SPA because:

- **Speed of development** — Forms, tables, and insights stay as Rails views and controllers. There is no second build pipeline, duplicate validation logic, or API contract to maintain for every screen change.
- **Lower total cost of ownership (TCO)** — Fewer moving parts (no Node/React version matrix for the main UI), smaller operational surface, and onboarding stays “one Rails app” for most features.
- **Fit for this product** — HR lists and charts are document-style workflows with server-driven HTML; Turbo Frames/Streams give partial updates without shipping a large client bundle.

React remains a strong choice when you need a highly interactive client-only experience or a shared API across many non-Rails clients; for this app, Hotwire matches the product and team efficiency goals.

## Code style (RuboCop)

Linting uses **`rubocop-rails-omakase`**, which builds on RuboCop’s defaults and Rails conventions and aligns with the wider **[Ruby Style Guide](https://rubystyle.guide/)** community practice.

```bash
bin/rubocop
# or
bundle exec rubocop
```

Auto-correct safe cops:

```bash
bundle exec rubocop -A
```

Configuration lives in **`.rubocop.yml`**.

## Schema annotations (Annotate)

Model files can include a **schema comment block** at the top (table name, columns, indexes) maintained by the **annotate** gem.

After changing the schema (e.g. new migrations), refresh annotations:

```bash
bundle exec annotate
```

## Setup

Prerequisites: **Ruby** (see `.ruby-version`), **Bundler**, **SQLite** (no separate server required for development).

```bash
bundle install
bin/rails db:prepare
```

## Seed data (10k employees)

Loads name lists from `lib/data/*.txt` and bulk-inserts 10,000 employees. Skip with `SKIP_EMPLOYEE_SEED=1` if you only want an empty database.

```bash
bin/rails db:seed
```

## Tests

```bash
bundle exec rspec
```

## Development server

```bash
bin/dev
```

This runs the Rails server and Tailwind watcher (see `Procfile.dev`). Alternatively: `bin/rails server` and run Tailwind separately if needed.

## Insights

Open **Salary insights** from the UI or visit `/insights`. Charts use **Chartkick** with data from `SalaryStatsQuery` (aggregations run in SQL).
