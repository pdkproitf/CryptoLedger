# CryptoLedger API

A Rails 7, API-only service for managing user accounts and transactions across multiple currencies (fiat and crypto). It exposes endpoints to list accounts, create and list transactions, and provides a clean, extensible design suitable for real-world growth.

## Highlights
- Rails 7 (API-only) with PostgreSQL
- JSON:API-style responses via serializers
- Strong referential integrity (FKs) and PostgreSQL ENUMs
- Service objects for business logic (creation and filtering)
- Clean authentication concern for simple header-based auth

## Architecture Overview
### Data Model
- Currency
    - Primary key: `currency` (string, e.g., "BTC")
    - Attributes: `name`, `precision`, `status`, `currency_type`
    - Backed by a dedicated `currencies` table; accounts reference this via FK for consistency and validation.

- Account
    - Belongs to `user`
    - Foreign key: `currency` → `currencies.currency`
    - Status stored as a PostgreSQL enum (`active`, `locked`, `closed`)
    - Balance is computed from ledger entries (credits − debits)

- Transaction
    - Belongs to `user`
    - Optional `from_account` and `to_account` (supports deposits, withdrawals, and trades)
    - Attributes: `transaction_type`, `amount`, `exchange_rate`, `notes`
    - Validation: `from_account` and `to_account` cannot be the same when both are present

### Patterns Used
- Service objects
    - `Factories::CreateTransaction` handles validation and atomic creation
    - `Transactions::FilterService` composes and applies filtering logic (type, currency)
- JSON:API response format via serializers
- DB-level constraints and enums for correctness and performance

## API
Base path: `/api/v1`

### Authentication
Supply a simple header for development/testing:
- `user-id: <id>`

Requests without a valid user will receive `401 Unauthorized`.

### Accounts
`GET /api/v1/accounts`
- Returns the current user's accounts in JSON:API format
- Balance is computed dynamically
- Roadmap: pagination, sparse fieldsets (`fields[accounts]=currency,balance`), filter by status

### Transactions
`GET /api/v1/transactions`
- Filters:
    - `type` — comma-separated (e.g., `deposit,withdrawal,trade`)
    - `currency` — comma-separated codes (e.g., `BTC,ETH`); matches when the currency is on either side of a transaction
- Implemented via `Transactions::FilterService`
- Roadmap: pagination, date range, amount range, ordering

`POST /api/v1/transactions`
- Creates a deposit, withdrawal, or trade
- Strong parameters; business rules delegated to `Factories::CreateTransaction`
- Returns serialized resource or standardized error payload

### Error Format
Consistent JSON:API-style errors:
```json
{ "errors": [ { "detail": "message" } ] }
```

## Setup & Running
Prerequisites:
- Ruby 3.2.2
- Bundler
- PostgreSQL (required; uses PostgreSQL ENUMs)

Steps:
1) Install gems
     - `bundle install`
2) Create database
     - `rails db:create`
3) Run migrations
     - `rails db:migrate`
4) Seed initial data (currencies, sample users, etc.)
     - `rails db:seed`
5) Start the server
     - `rails s` (API at http://localhost:3000)

## Testing
- Run the full suite: `bundle exec rspec`

## Design Decisions & Notes
- Currency normalization: A central `currencies` table with string PK (`currency`) ensures consistent codes and allows rich attributes.
- Referential integrity: `accounts.currency` is an FK to `currencies.currency`.
- PostgreSQL enums: Account `status` stored as a native enum for safety and speed.
- Service layer: Complex logic (e.g., transaction creation, filtering) lives in service objects for clarity and testability.
- JSON:API: Predictable envelopes and attributes structure for clients.

## Roadmap
- Authentication: JWT, OTP, passkeys; verification flows
- User activity/audit logging (immutable, append-only)
- Pagination and sparse fieldsets for accounts and transactions
- Advanced filters (date range, amount min/max), sorting
- Rate limiting and API keys for external use
- Idempotency keys for write operations

## Tools
- Postman collection: `crypto_accounting.postman_collection` (import to explore endpoints)

---
Questions, ideas, or proposals are welcome—this service is designed to be extended.
