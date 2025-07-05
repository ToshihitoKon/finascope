# TODO List

## TODO: API Error Handling

### Problem
Currently, `InvalidArgument` exceptions are not properly handled in the API layer. When these exceptions are raised in service classes, they result in 500 Internal Server Error responses instead of appropriate HTTP status codes.

### Current State
- `InvalidArgument` exceptions are raised in various service classes:
  - `services/invoice_records.rb` - DTO validation, empty update params, payment method not found
  - `services/payment_methods.rb` - DTO validation, empty update params
  - `services/categories.rb` - Empty update params
  - `services/records.rb` - Empty update params
- No `rescue_from` blocks or exception handling in API layer
- Results in 500 errors instead of proper 400 Bad Request responses

### Solution Approach
1. **Add Grape rescue_from blocks** in API root (`api/app/api/root.rb`)
2. **Map InvalidArgument to 400 Bad Request** status code
3. **Implement consistent error response format**
4. **Consider adding other exception mappings** for comprehensive error handling

### Implementation Example
```ruby
# In api/app/api/root.rb
rescue_from Exceptions::InvalidArgument do |e|
  error!({ error: e.message, status: 400 }, 400)
end
```

### Priority
Medium - Affects API usability and debugging experience

## TODO: Invoice Records API Parameter Validation Fix

### Problem
The `api/app/api/v1/invoice_records.rb` endpoint has incorrect parameter validation syntax, causing required parameters to not be properly validated and allowing bad requests to proceed without proper validation.

### Current Issues
1. **Incorrect params block placement** - `params do` blocks are inside HTTP method blocks instead of before them
2. **Wrong validation method** - Using `require` instead of `requires` 
3. **Affects multiple endpoints**:
   - `post` endpoint (lines 42-48)
   - `put ':id'` endpoint (lines 70-76)  
   - `delete ':id'` endpoint (lines 100-103)
   - `get :category_aggregation` endpoint (lines 115-121)

### Current Code Pattern (Incorrect)
```ruby
post do
  params do
    require :amount, type: Integer, desc: 'Invoice record amount'
    # ... other params
  end
  # ... endpoint logic
end
```

### Required Fix Pattern (Correct)
```ruby
params do
  requires :amount, type: Integer, desc: 'Invoice record amount'
  # ... other params
end
post do
  # ... endpoint logic
end
```

### Impact
- Required parameters are not validated
- Bad requests with missing parameters proceed to business logic
- May cause unclear error messages or unexpected behavior

### Priority
High - Affects API data integrity and error handling
