# TODO: API Error Handling

## Problem
Currently, `InvalidArgument` exceptions are not properly handled in the API layer. When these exceptions are raised in service classes, they result in 500 Internal Server Error responses instead of appropriate HTTP status codes.

## Current State
- `InvalidArgument` exceptions are raised in various service classes:
  - `services/invoice_records.rb` - DTO validation, empty update params, payment method not found
  - `services/payment_methods.rb` - DTO validation, empty update params
  - `services/categories.rb` - Empty update params
  - `services/records.rb` - Empty update params
- No `rescue_from` blocks or exception handling in API layer
- Results in 500 errors instead of proper 400 Bad Request responses

## Solution Approach
1. **Add Grape rescue_from blocks** in API root (`api/app/api/root.rb`)
2. **Map InvalidArgument to 400 Bad Request** status code
3. **Implement consistent error response format**
4. **Consider adding other exception mappings** for comprehensive error handling

## Implementation Example
```ruby
# In api/app/api/root.rb
rescue_from Exceptions::InvalidArgument do |e|
  error!({ error: e.message, status: 400 }, 400)
end
```

## Priority
Medium - Affects API usability and debugging experience