# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Finascope is a personal finance management application with a microservices architecture:
- **Backend API**: Ruby/Grape framework with ActiveRecord and MySQL
- **Frontend**: SvelteKit with TypeScript and Firebase Auth
- **Database**: MySQL 8.0 with encrypted user data
- **Infrastructure**: Docker containers with Nginx reverse proxy

## Directory Structure

```
finascope/
├── api/                              # Backend API (Ruby/Grape)
│   ├── app/api/
│   │   ├── root.rb                   # Main API root with helpers
│   │   └── v1/                       # API version 1
│   │       ├── categories.rb         # Categories CRUD endpoints
│   │       ├── invoice_records.rb    # Invoice records endpoints
│   │       ├── payment_methods.rb    # Payment methods CRUD endpoints
│   │       ├── records.rb            # Finance records CRUD endpoints
│   │       ├── root.rb               # V1 API root
│   │       ├── view.rb               # Aggregation/view endpoints
│   │       └── entities/             # Grape response entities
│   │           ├── categories.rb     # Category response format
│   │           ├── common.rb         # Common response structures
│   │           ├── invoice_records.rb
│   │           ├── payment_methods.rb
│   │           ├── records.rb        # Record response format
│   │           └── view.rb           # View/aggregation response format
│   ├── constants.rb                  # Application constants (TODO_ID, etc.)
│   ├── db/
│   │   ├── connection.rb             # Database connection setup
│   │   ├── models.rb                 # ActiveRecord models
│   │   └── repositories.rb           # Data access layer
│   ├── envs.rb                       # Environment configuration
│   ├── lib/                          # Utility libraries
│   │   ├── exceptions.rb             # Custom exception classes
│   │   ├── firebase.rb               # Firebase JWT verification
│   │   ├── id.rb                     # ID generation utilities
│   │   └── user_hash.rb              # User data encryption/decryption
│   ├── scripts/                      # Utility scripts
│   │   ├── create_database.rb        # Database initialization
│   │   └── finascope-console.rb      # Interactive console
│   └── services/                     # Business logic layer
│       ├── categories.rb             # Category business logic
│       ├── invoice_records.rb        # Invoice processing logic
│       ├── payment_methods.rb        # Payment method logic
│       ├── records.rb                # Finance record logic
│       └── view.rb                   # Aggregation/view logic
├── front/                            # Frontend (SvelteKit)
│   ├── src/
│   │   ├── app.html                  # Main HTML template
│   │   ├── app.css                   # Global styles
│   │   ├── lib/
│   │   │   ├── api/v1/               # API client layer
│   │   │   │   ├── api.ts            # Main API client functions
│   │   │   │   ├── const.ts          # Frontend constants (TodoIds, etc.)
│   │   │   │   ├── index.ts          # API exports
│   │   │   │   ├── types.d.ts        # TypeScript API types
│   │   │   │   └── mock/             # Mock data for development
│   │   │   ├── firebase/
│   │   │   │   └── index.svelte.ts   # Firebase auth integration
│   │   │   └── utils.ts              # Utility functions
│   │   └── routes/                   # SvelteKit pages/routes
│   │       ├── +layout.svelte        # Root layout
│   │       ├── +page.svelte          # Home page
│   │       └── [pages]/             # Application pages (to be implemented)
│   ├── static/                       # Static assets
│   ├── package.json                  # Frontend dependencies
│   ├── svelte.config.js             # SvelteKit configuration
│   ├── tsconfig.json                # TypeScript configuration
│   └── vite.config.ts               # Vite build configuration
├── mysql/
│   └── init.d/
│       └── 00_user_database.sql     # Database initialization SQL
├── nginx/                           # Nginx reverse proxy
│   ├── Dockerfile
│   └── files/
│       ├── conf.d/
│       └── nginx.conf
├── compose.yml                      # Production Docker Compose
├── compose-dev.yml                  # Development Docker Compose
├── compose-dev-mysql.yml            # Shared MySQL for development
└── CLAUDE.md                        # This documentation file
```

### Key Directory Purposes

**Backend (`api/`):**
- `app/api/v1/`: REST API endpoints organized by resource
- `entities/`: Response data serialization (JSON structure definitions)  
- `services/`: Business logic layer (core application logic)
- `db/repositories.rb`: Data access layer (database queries)
- `lib/`: Utility libraries (encryption, Firebase, etc.)
- `constants.rb`: Application-wide constants

**Frontend (`front/src/`):**
- `lib/api/v1/`: API client and type definitions
- `lib/firebase/`: Firebase authentication integration
- `routes/`: SvelteKit pages following file-based routing

**Key Files for Common Tasks:**
- Adding new API endpoint: `api/app/api/v1/[resource].rb`
- Adding new page: `front/src/routes/[page]/+page.svelte`
- Database queries: `api/db/repositories.rb`
- Business logic: `api/services/[resource].rb`
- API types: `front/src/lib/api/v1/types.d.ts` (to be implemented)
- Constants: `api/constants.rb` and `front/src/lib/api/v1/const.ts` (to be implemented)

## Development Commands

### Quick Start with Makefile (Recommended)
```bash
# Show all available commands
make help

# Start development environment (background)
make dev

# Update database schema (after model changes)
make schema-update

# View logs
make logs

# Access API console
make console

# Connect to API container shell
make api-shell

# Connect to MySQL shell
make db-shell

# Stop and clean up
make clean
```

### Local Development (Manual Commands)
```bash
# First time: Start shared MySQL database
docker compose -f compose-dev-mysql.yml up -d

# Start full development environment (any worktree)
docker compose -f compose-dev.yml up

# Access points:
# - Frontend: http://localhost:8080 (via nginx)
# - API: http://localhost:9292 (direct)
# - MySQL: localhost:3306 (shared across all worktrees)
```

### Individual Services

**API Development:**
```bash
cd api
bundle install
bundle exec rerun -- rackup
# Runs on http://localhost:9292
```

**Frontend Development:**
```bash
cd front
pnpm install
pnpm dev
# Runs on http://localhost:5173
```

**Frontend Linting & Type Checking:**
```bash
cd front
pnpm lint          # Prettier + ESLint
pnpm check         # Svelte type checking
pnpm format        # Format code
```

## Architecture Patterns

### Security Model
The application implements a privacy-first encryption system:
- User identification via Firebase Auth UID
- Data encrypted using user-specific hashes (see `api/lib/user_hash.rb`)
- User data tables isolated with separate salt (`UserHash#user_info_hash`)
- No direct foreign key relations between user data and other tables

### API Structure
- **Framework**: Grape API with JSON format
- **Authentication**: Firebase JWT Bearer tokens
- **Entities**: Grape entities for response serialization (`api/app/api/v1/entities/`)
- **Services**: Business logic layer (`api/services/`)
- **Repositories**: Data access layer (`api/db/repositories.rb`)

### Frontend Architecture
- **Framework**: SvelteKit 5 with TypeScript
- **Authentication**: Firebase Auth with JWT token management
- **API Client**: To be implemented in `front/src/lib/api/v1/api.ts`

### Database Design
- **Models**: ActiveRecord models in `api/db/models.rb`
- **Encryption**: Sensitive fields prefixed with `encrypted_` 
- **Pagination**: Kaminari gem for API pagination
- **Connection**: MySQL via `api/db/connection.rb`

## Key Implementation Notes

### User Data Encryption
All user-sensitive data is encrypted using the `UserHash` class:
```ruby
uhash = UserHash.new(firebase_uid)
encrypted_data = uhash.encrypt(sensitive_string)
decrypted_data = uhash.decrypt(encrypted_data)
```

### API Authentication
Every API endpoint expects Firebase JWT tokens:
```ruby
# In API helpers (api/app/api/root.rb)
def request_userdata
  jwt = authorization_header&.gsub("Bearer ", "")
  Firebase.decode_jwt(jwt)
end
```

### Frontend API Communication
API calls will include Firebase JWT tokens:
```typescript
// API calls to be implemented in front/src/lib/api/v1/api.ts
const jwt = await getFirebaseToken();
opts.headers['Authorization'] = `Bearer ${jwt}`;
```

### TODO Item Handling
The application uses special TODO IDs for records with unset categories or payment methods:

**TODO ID Constants:**
- Frontend: `front/src/lib/api/v1/const.ts` - `TodoIds.Category` and `TodoIds.PaymentMethod` (to be implemented)
- Backend: `api/constants.rb` - `TODO_ID[:category]` and `TODO_ID[:payment_method]`
- Values: `'TODO_CATEGORY_ID'` and `'TODO_PAYMENT_METHOD_ID'`

**Implementation Details:**
- Records can be created with `category_id: 'TODO_CATEGORY_ID'` for unset categories
- TODO items are displayed as "TODO" in both lists and aggregations
- Frontend record creation dialog will include TODO as default option (to be implemented)
- Backend repositories use `left_joins(:category)` to include TODO items in aggregations
- TODO records are fully functional - can be created, edited, and aggregated

**Creating TODO Records:**
```bash
# Create a TODO record (category and payment method unset)
curl -X POST "http://localhost:8080/finascope/api/v1/records" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "未分類の支出",
    "type_id": 1,
    "state_id": 1, 
    "description": "カテゴリ未設定のレコード",
    "amount": 1500,
    "category_id": "TODO_CATEGORY_ID",
    "date": "2025-01-01",
    "payment_method_id": "TODO_PAYMENT_METHOD_ID"
  }'
```

**TODO Items in Category Aggregation:**
TODO items appear as a separate "TODO" category in `/view/categories/aggregation` and can be clicked to see detailed records.

## Testing & Quality

Currently, no automated test suite is configured. When adding tests:
- For API: Consider RSpec or similar Ruby testing framework
- For Frontend: Consider Vitest with SvelteKit testing utilities

### Manual API Testing

**Anonymous User Testing:**
When testing API endpoints without authentication, the system automatically uses an anonymous user. This allows for easy manual testing:

```bash
# Test endpoints without Authorization header
curl -X GET "http://localhost:8080/finascope/api/v1/view/categories/aggregation" -H "Content-Type: application/json"
```

**Creating Sample Data for Testing:**

1. **Create a Category:**
```bash
curl -X POST "http://localhost:8080/finascope/api/v1/categories" \
  -H "Content-Type: application/json" \
  -d '{"label": "食費"}'
# Returns: {"status":"success","id":"CATEGORY_ID"}
```

2. **Create a Payment Method:**
```bash
curl -X POST "http://localhost:8080/finascope/api/v1/payment_methods" \
  -H "Content-Type: application/json" \
  -d '{"label": "現金", "withdrawal_day_of_month": 1}'
# Returns: {"status":"success","id":"PAYMENT_METHOD_ID"}
```

3. **Create Records:**
```bash
# Replace CATEGORY_ID and PAYMENT_METHOD_ID with actual IDs from steps 1-2
curl -X POST "http://localhost:8080/finascope/api/v1/records" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "ランチ",
    "type_id": 1,
    "state_id": 1,
    "description": "コンビニで昼食",
    "amount": 1000,
    "category_id": "CATEGORY_ID",
    "date": "2025-01-01",
    "payment_method_id": "PAYMENT_METHOD_ID"
  }'

curl -X POST "http://localhost:8080/finascope/api/v1/records" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "夕食",
    "type_id": 1,
    "state_id": 1,
    "description": "スーパーで買い物",
    "amount": 2500,
    "category_id": "CATEGORY_ID",
    "date": "2025-01-02",
    "payment_method_id": "PAYMENT_METHOD_ID"
  }'
```

4. **Test Category Aggregation:**
```bash
# 期間未指定（今月のデータを取得）
curl -X GET "http://localhost:8080/finascope/api/v1/view/categories/aggregation" \
  -H "Content-Type: application/json"

# 期間指定（両方の日付が必要）
curl -X GET "http://localhost:8080/finascope/api/v1/view/categories/aggregation?begin_date=2025-01-01&end_date=2025-01-31" \
  -H "Content-Type: application/json"

# バリデーションエラー例（片方の日付のみ指定）
curl -X GET "http://localhost:8080/finascope/api/v1/view/categories/aggregation?begin_date=2025-01-01" \
  -H "Content-Type: application/json"
# Returns: {"error":"Both begin_date and end_date must be specified together"}
```

**Required Record Fields:**
- `title`: Record title (string)
- `type_id`: Record type ID (integer, typically 1)
- `state_id`: Record state ID (integer, typically 1)
- `description`: Record description (string)
- `amount`: Amount in cents/smallest currency unit (integer)
- `category_id`: Category ID from categories endpoint (string)
- `date`: Date in YYYY-MM-DD format (string)
- `payment_method_id`: Payment method ID from payment_methods endpoint (string)

## Database Operations

**Database Setup:**
```bash
# Initial setup handled by Docker init scripts
# See mysql/init.d/00_user_database.sql
```

**Console Access:**
```bash
cd api
bundle exec ruby scripts/finascope-console.rb
```

## Testing & Quality Assurance

### API Endpoint Testing

**Basic Health Check:**
```bash
curl -s http://localhost:8080/finascope/api/v1/healthcheck
# Expected: {"status":"healthy"}
```

**Complete API Testing Workflow:**
```bash
# 1. Test categories endpoint
curl -s http://localhost:8080/finascope/api/v1/categories
curl -s -X POST http://localhost:8080/finascope/api/v1/categories \
  -H "Content-Type: application/json" \
  -d '{"label": "食費"}'

# 2. Test payment methods endpoint
curl -s http://localhost:8080/finascope/api/v1/payment_methods
curl -s -X POST http://localhost:8080/finascope/api/v1/payment_methods \
  -H "Content-Type: application/json" \
  -d '{"label": "現金", "withdrawal_day_of_month": 1}'

# 3. Test records endpoint
curl -s http://localhost:8080/finascope/api/v1/records
curl -s -X POST http://localhost:8080/finascope/api/v1/records \
  -H "Content-Type: application/json" \
  -d '{
    "title": "ランチ",
    "type_id": 1,
    "state_id": 1,
    "description": "テスト用レコード",
    "amount": 1000,
    "category_id": "CATEGORY_ID",
    "date": "2025-01-01",
    "payment_method_id": "PAYMENT_METHOD_ID"
  }'

# 4. Test aggregation endpoint
curl -s "http://localhost:8080/finascope/api/v1/view/categories/aggregation"
```

**All Endpoints Status Check:**
- ✅ `/healthcheck` - Health status
- ✅ `/categories` - Category CRUD operations
- ✅ `/payment_methods` - Payment method CRUD operations
- ✅ `/records` - Finance record CRUD operations
- ✅ `/view/categories/aggregation` - Data aggregation and reporting

### Code Quality & Formatting

**Rubocop (Ruby Code Formatter):**
```bash
cd api

# Check current formatting issues
rubocop

# Auto-fix basic formatting issues
rubocop --autocorrect

# Auto-fix all safe corrections (including unsafe ones)
rubocop -A

# Check specific files
rubocop app/api/v1/records.rb
```

**Rubocop Configuration:**
- Integrated into the Ruby API codebase
- Enforces consistent code style across all Ruby files
- Fixes common issues: string quotes, frozen string literals, whitespace, etc.
- Run before committing changes to maintain code quality

**Common Rubocop Fixes Applied:**
- Add `# frozen_string_literal: true` to all Ruby files
- Normalize string quotes (double → single quotes)
- Remove trailing whitespace
- Add empty lines after magic comments
- Fix basic syntax and style violations

**Creating Format Fix Branches:**
```bash
# Create branch from main
git checkout main
git checkout -b style/rubocop-format-fixes

# Apply auto-corrections
cd api && rubocop -A

# Commit changes
git add -A
git commit -m "style: apply Rubocop auto-corrections for basic formatting"

# Test all endpoints after formatting
curl -s http://localhost:8080/finascope/api/v1/healthcheck
# Continue with full API testing...
```

**Note:** Always verify API functionality after applying Rubocop changes. In rare cases, a server restart may be needed to reload modified files properly.

## Deployment Notes

- Frontend builds static assets: `pnpm build`
- Production deployment uses static adapter for SvelteKit
- GCP deployment configured via `pnpm deploy` script
- Environment variables managed through Docker compose files