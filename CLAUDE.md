# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Finascope is a personal finance management application with a microservices architecture:
- **Backend API**: Ruby/Grape framework with ActiveRecord and MySQL
- **Frontend**: SvelteKit with TypeScript and Firebase Auth
- **Database**: MySQL 8.0 with encrypted user data
- **Infrastructure**: Docker containers with Nginx reverse proxy

## Directory Structure

### Backend (`api/`)
- `app/api/`: API endpoint definitions
  - `root.rb`: Main API root with authentication helpers
  - `v1/`: Versioned API endpoints organized by resource (categories, records, payment_methods, invoice_records, view)
  - `v1/entities/`: Grape entities for response serialization
- `db/`: Database layer
  - `models.rb`: ActiveRecord model definitions
  - `repositories.rb`: Data access layer with query methods
  - `connection.rb`: Database connection configuration
- `services/`: Business logic layer for each resource
- `lib/`: Utility libraries (user data encryption, Firebase JWT verification, ID generation, exceptions)
- `constants.rb`: Application-wide constants
- `envs.rb`: Environment variable configuration
- `scripts/`: Utility scripts for database setup and console access

### Frontend (`front/`)
- `src/lib/`: Shared libraries
  - `api/v1/`: API client layer with type definitions and mock data
  - `firebase/`: Firebase authentication integration
  - `utils.ts`: Utility functions
- `src/routes/`: SvelteKit pages following file-based routing
- `src/app.html`, `src/app.css`: Application template and global styles
- Configuration files: `package.json`, `svelte.config.js`, `tsconfig.json`, `vite.config.ts`

### Infrastructure
- `mysql/init.d/`: Database initialization SQL scripts
- `nginx/`: Nginx reverse proxy configuration and Dockerfile
- `compose*.yml`: Docker Compose configurations for production and development environments

### Key Files for Common Tasks
- Adding API endpoint: `api/app/api/v1/[resource].rb`
- Adding page: `front/src/routes/[page]/+page.svelte`
- Database queries: `api/db/repositories.rb`
- Business logic: `api/services/[resource].rb`
- API types: `front/src/lib/api/v1/types.d.ts`
- Constants: `api/constants.rb` and `front/src/lib/api/v1/const.ts`

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

### Frontend Implementation Guidelines

**Component Structure:**
- Create Svelte components in `src/lib/components/` and import them in `src/routes/`
- Components should be self-contained and reusable

**Styling Approach:**
- Define global CSS variables in `src/app.css`
- Reference global variables in component styles
- Follow BEM methodology: treat components as Blocks, define Elements and Modifiers within component styles
- Route files (`src/routes/`) should only contain layout-related styles for component positioning
- Component-specific styles should be defined within the component's `<style>` block

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

### TODO Item Handling (Deplecated)
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

**TODO Items in Category Aggregation:**
TODO items appear as a separate "TODO" category in `/view/categories/aggregation` and can be clicked to see detailed records.

## Database Operations

**Console Access:**
```bash
cd api
bundle exec ruby scripts/finascope-console.rb
```

## Deployment Notes

- Frontend builds static assets: `pnpm build`
- Production deployment uses static adapter for SvelteKit
- GCP deployment configured via `pnpm deploy` script
- Environment variables managed through Docker compose files
