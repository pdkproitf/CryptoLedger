## Project Notes

### Setup & Bootstrapping
Run the following to get the application ready (order matters):

1. Install gems:
	 - `bundle install`
2. Create the database:
	 - `rails db:create`
3. Run migrations:
	 - `rails db:migrate`
4. Seed initial data (currencies, sample users, etc.):
	 - `rails db:seed`

### Evaluation / Tooling
- Run the full test suite: `bundle exec rspec` (or `rails spec` if aliased)
- API exploration: Import the Postman collection (`crypto_accounting.postman_collection`) for sample requests.

### API Standards
- Versioned endpoints under `api/v1/`.
- Consistent JSON:API compliant responses (data, attributes, meta, errors).
- Unified error format: `{ errors: [ { detail: "message" } ] }` with appropriate HTTP status codes.

### Accounts
Endpoint: `GET /api/v1/accounts`
- Requires authentication.
- Returns only the current user's accounts.
- Serializer outputs JSON:API structure.
- Balance computed from ledger transactions (credits - debits).
- TODO:
	- Pagination (page + per_page)
	- Sparse fieldsets (e.g. `fields[accounts]=currency,balance`)
	- Filtering by status.

### Transactions
Endpoints:
1. `GET /api/v1/transactions`
	 - Auth required.
	 - Supports filtering:
		 - `type=` comma-separated list (deposit, withdrawal, trade)
		 - `currency=` comma-separated currency codes; matches transactions where the currency appears on either side.
	 - Uses `Transactions::FilterService` for composition & testability.
	 - TODO: pagination, date range filter, min/max amount, ordering.

2. `POST /api/v1/transactions`
	 - Auth required.
	 - Strong parameters enforced.
	 - Business logic delegated to `Factories::CreateTransaction` (validations & atomic creation).
	 - Returns serialized transaction or standardized error payload.


### Error Handling Strategy
- Return consistent structure; no mixing ad-hoc keys.
- Use 4xx for client issues (422 for validation, 404 for not found, 401 for auth, 403 for forbidden) and 5xx for server faults.

### Account: Potential Helpful Columns / Enhancements
- Account `status` enum (active, closed, locked) — already implemented.
- Account `kind` (user vs system) for internal float or treasury accounts.
- Transaction `reference` or `external_id` for reconciliation with crypto transaction hash

### Scaling to 100+ Currency Pairs
#### Currency Model
- Backed by `currencies` table with primary key `currency` (e.g. "BTC").
- Attributes: `name`, `precision`, `status`, `currency_type` (fiat/crypto).
- Accounts reference currency codes directly for referential integrity.
- Central `currencies` table ensures consistency and validation.
- Add caching for frequently accessed currency data.

### Future Work / TODO
- Add pagination for accounts & transactions.
- Implement sparse fieldsets & inclusion of related resources.
- Add rate limiting & API key support (if external use grows).
- Introduce audit logging for compliance (immutable append-only log).
- Formalize service layer (transaction lifecycle events, balance projections).

### Questions & Answers
Q: How do we extend to many currencies?
A: Normalize via the `currencies` table and reference by code; enrich with type, precision, status; enforce FK constraints; optionally cache.

Q: How are errors communicated?
A: Consistent JSON:API error objects with correct HTTP status; avoid leaking internal exception details.

Q: What additional columns help accounting integrity?
A: Status enums, kind (system vs user), audit timestamps, and potentially locking/versioning fields.
