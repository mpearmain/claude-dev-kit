# Code Quality Standards

## Language: {{MAIN_LANGUAGE}}

## Documentation Standards

### JavaScript/TypeScript

#### JSDoc Requirements
Every exported function, class, and complex internal function must have JSDoc:

```javascript
/**
 * Brief description of what the function does.
 *
 * Detailed explanation if needed, including:
 * - Key algorithms or logic
 * - Side effects
 * - Important assumptions
 *
 * @param {string} param1 - Description of param1
 * @param {Object} options - Configuration object
 * @param {boolean} options.flag - Description of flag
 * @returns {Promise<Result>} Description of return value
 * @throws {ErrorType} When this error occurs
 *
 * @example
 * const result = await functionName('value', { flag: true });
 */
```

#### State Machines and Complex Logic
Document state transitions and business logic:

```javascript
/**
 * State machine for order processing.
 *
 * States:
 * - PENDING: Initial state, awaiting payment
 * - PROCESSING: Payment received, preparing order
 * - SHIPPED: Order dispatched
 * - DELIVERED: Order completed
 * - CANCELLED: Order cancelled
 *
 * Transitions:
 * - PENDING -> PROCESSING: When payment confirmed
 * - PROCESSING -> SHIPPED: When dispatch complete
 * - SHIPPED -> DELIVERED: When delivery confirmed
 * - Any -> CANCELLED: When cancellation requested
 */
```

### Python

#### Docstring Requirements
Every public function, class, and module must have docstrings:

```python
def function_name(param1: str, param2: Optional[Dict[str, Any]] = None) -> Result:
    """
    Brief description of what the function does.

    Detailed explanation if needed, including:
    - Key algorithms or logic
    - Side effects
    - Important assumptions

    Args:
        param1: Description of param1
        param2: Optional configuration dictionary with keys:
            - key1: Description
            - key2: Description

    Returns:
        Description of the return value and its structure

    Raises:
        ErrorType: When this error occurs
        ValueError: When invalid parameters provided

    Example:
        >>> result = function_name("value", {"key1": "val1"})
        >>> print(result)
        Result(...)
    """
```

#### Type Hints
All function signatures must include type hints:

```python
from typing import List, Optional, Dict, Any, Union

def process_data(
    items: List[str],
    config: Optional[Dict[str, Any]] = None,
    strict: bool = False
) -> Union[Result, List[Result]]:
    ...
```

## Dead Code Removal

### Patterns to Remove

1. **Commented Code Blocks**
   ```javascript
   // DELETE THIS:
   // function oldImplementation() {
   //   ...
   // }
   ```

2. **Unused Imports**
   ```python
   # DELETE THIS:
   from unused_module import unused_function
   ```

3. **Deprecated Functions**
   ```javascript
   // DELETE THIS:
   /** @deprecated Use newFunction instead */
   function deprecatedFunction() {}
   ```

4. **Console Logs (Production)**
   ```javascript
   // DELETE THIS (in production):
   console.log('debug:', data);
   ```

5. **TODO Comments Without Tickets**
   ```python
   # DELETE OR CREATE TICKET:
   # TODO: Implement this later
   ```

## Code Organization

### File Structure
- One class/component per file
- Related utilities in separate files
- Clear separation of concerns

### Import Order
1. Standard library imports
2. Third-party imports
3. Local application imports
4. Relative imports

### Naming Conventions
- **Functions/Methods**: camelCase (JS), snake_case (Python)
- **Classes**: PascalCase
- **Constants**: UPPER_SNAKE_CASE
- **Files**: kebab-case or snake_case

## Testing Standards

### Test Coverage Requirements
- Minimum {{MIN_COVERAGE}}% coverage
- All public APIs must have tests
- Edge cases must be tested

### Test Structure
```javascript
describe('ComponentName', () => {
  describe('methodName', () => {
    it('should handle normal case', () => {
      // Arrange
      // Act
      // Assert
    });

    it('should handle edge case', () => {
      // Test edge cases
    });

    it('should throw error when invalid', () => {
      // Test error conditions
    });
  });
});
```

## Performance Considerations

- Avoid N+1 queries
- Implement pagination for lists
- Cache expensive computations
- Use lazy loading where appropriate
- Profile before optimizing

## Security Checklist

- [ ] Input validation on all user data
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output encoding)
- [ ] CSRF tokens for state-changing operations
- [ ] Authentication and authorization checks
- [ ] Sensitive data encryption
- [ ] Secure session management
- [ ] Rate limiting on APIs