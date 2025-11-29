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

# Questions & Answers
### 1. How you would extend the system to support 100+ currency pairs?
- Normalize via the `currencies` table and reference by code; enrich with type, precision, status; enforce FK constraints; optionally cache.
#### Currency Model
- Backed by `currencies` table with primary key `currency` (e.g. "BTC").
- Attributes: `name`, `precision`, `status`, `currency_type` (fiat/crypto).
- Accounts reference currency codes directly for referential integrity.
- Central `currencies` table ensures consistency and validation.
- Add caching for frequently accessed currency data.

### 2. How are errors communicated?
- Consistent JSON:API error objects with correct HTTP status;
- Return consistent structure by implementing a generic helper for generating error json response.
- Capture exception in generic place to avoid leaking internal exception details.
- [TODO] Integrate monitoring platform such as Sentry, Bugsnag

### 3. What columns could you add to the accounting models that you think would be helpful?
- Status: active, lock, closed.
- Create a native enum at the database level (e.g., PostgreSQL ENUM type) for status to optimize queries, ensure data integrity, and improve performance.
- Type fund/future, etc

### 4. Future Work / TODO (Any other comments, questions, or thoughts that came up.)
- Implement JWT authentication, OTP, Passkey, Verification ....
- User's activities for tracking
- Add pagination for accounts & transactions.
- Implement sparse fieldsets & inclusion of related resources.
- Add rate limiting & API key support (if external use grows).
- Introduce audit logging for compliance (immutable append-only log).
