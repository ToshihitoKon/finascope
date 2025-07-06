# TODO List

## TODO: Security Vulnerability - Fixed IV in Encryption

### Problem
The encryption implementation in `user_hash.rb` uses a fixed IV (Initialization Vector) which compromises security by making identical plaintexts produce identical ciphertexts.

### Current State
- File: `/api/lib/user_hash.rb:26`
- Uses fixed IV for AES encryption
- Same plaintext always produces same ciphertext
- Violates cryptographic best practices

### Solution Approach
1. **Generate random IV** for each encryption operation
2. **Prepend IV to ciphertext** for storage/transmission
3. **Extract IV from ciphertext** during decryption
4. **Test encryption/decryption** with sample data

### Implementation Example
```ruby
# Generate random IV for each encryption
iv = cipher.random_iv
# Prepend IV to encrypted data
encrypted_data = iv + cipher.update(data) + cipher.final
```

### Priority
Critical - Immediate security fix required

## TODO: API Parameter Definition Inconsistency

### Problem
API endpoints use inconsistent parameter validation methods (`require` vs `requires`) and incorrect parameter block placement, causing validation failures.

### Current Issues
1. **Mixing validation methods** - Some endpoints use `require` instead of `requires`
2. **Incorrect params block placement** - `params do` blocks inside HTTP method blocks
3. **Affects multiple files**:
   - `/api/app/api/v1/records.rb:40` and `:77` (uses `require`)
   - `/api/app/api/v1/invoice_records.rb` (multiple endpoints with incorrect validation)

### Current Code Pattern (Incorrect)
```ruby
post do
  params do
    require :amount, type: Integer, desc: 'Amount'
  end
  # ... endpoint logic
end
```

### Required Fix Pattern (Correct)
```ruby
params do
  requires :amount, type: Integer, desc: 'Amount'
end
post do
  # ... endpoint logic
end
```

### Impact
- Required parameters are not validated
- Bad requests with missing parameters proceed to business logic
- Inconsistent API behavior across endpoints

### Priority
High - Affects API data integrity and error handling

## TODO: Error Handling Inconsistency

### Problem
API services mix standard exceptions with custom exceptions, and the API layer lacks proper exception handling, resulting in 500 errors instead of appropriate HTTP status codes.

### Current State
- Services use mixed exception types:
  - `/api/services/categories.rb:31` (uses `StandardError`)
  - `/api/services/records.rb:59` (uses `StandardError`)
  - Other services use `Exceptions::InvalidArgument`
- No `rescue_from` blocks in API layer
- Results in 500 errors instead of proper 400 Bad Request responses

### Solution Approach
1. **Standardize exception classes** - Use custom `Exceptions::InvalidArgument` throughout
2. **Add Grape rescue_from blocks** in API root (`api/app/api/root.rb`)
3. **Map exceptions to appropriate HTTP status codes**
4. **Implement consistent error response format**

### Implementation Example
```ruby
# In api/app/api/root.rb
rescue_from Exceptions::InvalidArgument do |e|
  error!({ error: e.message, status: 400 }, 400)
end
```

### Priority
High - Affects API usability and debugging experience

## TODO: Remove Debug Code from Production

### Problem
Debug output statements are left in production code, causing information leakage and performance degradation.

### Current Issues
- `/api/app/api/v1/invoice_records.rb:49` - `puts params.inspect`
- `/api/app/api/root.rb:29` - `puts e.inspect`

### Solution Approach
1. **Remove debug puts statements**
2. **Replace with proper logging** if needed
3. **Use conditional debug output** for development only

### Priority
High - Security and performance impact

## TODO: Database Query Optimization

### Problem
Potential N+1 query problems and inefficient eager loading in repository methods may cause performance degradation with large datasets.

### Current State
- Multiple repository methods use `eager_load`
- Some associations may not be properly optimized
- Risk of N+1 queries in complex data retrieval

### Solution Approach
1. **Review all repository methods** for query efficiency
2. **Optimize eager_load usage** and associations
3. **Add query performance monitoring**
4. **Test with large datasets**

### Priority
High - Performance impact with scale

## TODO: Code Duplication in Services

### Problem
Record formatting and validation logic is duplicated across multiple service classes, creating maintenance burden and inconsistent behavior.

### Current State
- Similar validation patterns in multiple services
- Duplicated record formatting logic
- Inconsistent error handling patterns

### Solution Approach
1. **Extract common methods** to shared modules or base classes
2. **Create common validation module**
3. **Standardize record formatting**
4. **Implement consistent error handling**

### Priority
Medium - Code maintainability and consistency

## TODO: Method Responsibility Overload

### Problem
The `monthly_records` method in `invoice_records.rb` is too long and complex, making it difficult to test and maintain.

### Current State
- File: `/api/services/invoice_records.rb:45-79`
- Method handles multiple responsibilities
- Complex logic difficult to test

### Solution Approach
1. **Break down into smaller methods** with single responsibilities
2. **Extract business logic** into separate methods
3. **Improve testability** with focused methods
4. **Add method documentation**

### Priority
Medium - Code maintainability

## TODO: Replace Magic Numbers with Constants

### Problem
Hardcoded numbers in closing date calculations make business logic unclear and difficult to modify.

### Current State
- File: `/api/db/repositories.rb:16-54`
- Direct numeric values in date calculations
- Unclear business rule implementation

### Solution Approach
1. **Define constants** for business rules
2. **Document business logic** in comments
3. **Make calculations** more readable
4. **Add configuration** for flexible rules

### Priority
Medium - Code clarity and maintainability

## TODO: Add Comprehensive Input Validation

### Problem
Various API endpoints have insufficient parameter type and range validation, potentially causing runtime errors and security issues.

### Current State
- Minimal parameter validation in some endpoints
- Missing type checking for dynamic parameters
- Potential for invalid data processing

### Solution Approach
1. **Add comprehensive validation** for all input parameters
2. **Implement type checking** and range validation
3. **Add business rule validation**
4. **Standardize validation patterns**

### Priority
Medium - Data integrity and security

## TODO: Clean Up TODO Comments

### Problem
Multiple files contain unresolved TODO comments indicating incomplete features and accumulating technical debt.

### Current State
- Various files have TODO comments
- Incomplete feature implementations
- Technical debt accumulation

### Solution Approach
1. **Review all TODO comments** in codebase
2. **Implement or remove** TODO items
3. **Track progress** on important features
4. **Document decisions** for removed items

### Priority
Low - Technical debt management

## TODO: Improve Documentation

### Problem
Various service and repository methods lack adequate documentation, reducing developer productivity.

### Current State
- Missing method documentation
- Unclear parameter descriptions
- Limited usage examples

### Solution Approach
1. **Add comprehensive method documentation**
2. **Document parameters** and return values
3. **Include usage examples**
4. **Add business logic explanations**

### Priority
Low - Developer experience
