# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Finascope is a personal finance management application with a microservices architecture:
- **Backend API**: Ruby/Grape framework with ActiveRecord and MySQL
- **Frontend**: SvelteKit with TypeScript, TailwindCSS, and Firebase Auth
- **Database**: MySQL 8.0 with encrypted user data
- **Infrastructure**: Docker containers with Nginx reverse proxy

## Development Commands

### Local Development (Recommended)
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
- **State**: Svelte stores with `svelte-persisted-store`
- **Authentication**: Firebase Auth with JWT token management
- **API Client**: Centralized in `front/src/lib/api/v1/api.ts`
- **UI Components**: shadcn/ui components in `front/src/lib/components/ui/`

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
API calls automatically include Firebase JWT tokens:
```typescript
// All API calls in front/src/lib/api/v1/api.ts handle auth
const jwt = await getFirebaseToken();
opts.headers['Authorization'] = `Bearer ${jwt}`;
```

## Testing & Quality

Currently, no automated test suite is configured. When adding tests:
- For API: Consider RSpec or similar Ruby testing framework
- For Frontend: Consider Vitest with SvelteKit testing utilities

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

## Deployment Notes

- Frontend builds static assets: `pnpm build`
- Production deployment uses static adapter for SvelteKit
- GCP deployment configured via `pnpm deploy` script
- Environment variables managed through Docker compose files