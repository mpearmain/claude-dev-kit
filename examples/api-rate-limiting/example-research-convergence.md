---
date: 2025-01-15T10:23:45Z
researcher: mpearmain
git_commit: abc123def456
branch: main
repository: example-api
topic: "API Authentication and Rate Limiting Integration"
tags: [research, api, authentication, middleware, rate-limiting]
status: complete
last_updated: 2025-01-15
last_updated_by: mpearmain
---

# Research: API Authentication and Rate Limiting Integration

**Date**: 2025-01-15T10:23:45Z
**Researcher**: mpearmain
**Git Commit**: abc123def456
**Branch**: main
**Repository**: example-api

## Research Question

How does our current API authentication work, and where would rate limiting integration fit in the middleware stack?

## Summary

Current API uses JWT-based authentication with middleware in `src/api/middleware/auth.py`. The authentication flow is well-established with three main components: token validation, user context injection, and permission checking. Rate limiting would integrate at the middleware layer, positioned before authentication to protect the auth endpoints themselves.

## High-Confidence Findings (Convergent)

Files/components identified by multiple agents from different analytical perspectives:

### src/api/middleware/auth.py - Found by 3 agents
- **codebase-locator perspective**: File search for "middleware" returned this as primary authentication middleware
- **codebase-analyzer perspective**: Import analysis from `src/api/app.py` identified this as critical middleware component
- **pattern-finder perspective**: Middleware pattern search found this implementing standard FastAPI middleware pattern
- **Significance**: Core authentication logic with 1 implementation file handling all auth. Any rate limiting must integrate with this middleware stack.
- **Location**: `src/api/middleware/auth.py:15-67`

### src/api/app.py - Found by 2 agents
- **codebase-locator perspective**: Entry point search identified this as FastAPI application setup
- **codebase-analyzer perspective**: Middleware registration analysis found middleware stack definition here
- **Significance**: Middleware registration order defined here. Rate limiting middleware must be added to this file.
- **Location**: `src/api/app.py:23-45`

## Detailed Findings

### Authentication Flow

**Entry Point**: `src/api/app.py:23-45`
```python
app = FastAPI(title="Example API")
app.add_middleware(CORSMiddleware, ...)
app.include_middleware(AuthenticationMiddleware)
```

Current middleware order:
1. CORS handling
2. Authentication (JWT validation)
3. Route handlers

**JWT Middleware**: `src/api/middleware/auth.py:15-67`
- Validates JWT tokens from Authorization header
- Extracts user ID and permissions
- Injects user context into request state
- Returns 401 for invalid/missing tokens

**Token Validation**: `src/auth/jwt.py:34-89`
- Uses PyJWT library
- RS256 algorithm with public key validation
- Token expiry checking
- Claims validation (iss, aud, exp)

### Current Middleware Stack Details

**File**: `src/api/middleware/auth.py`

```python
class AuthenticationMiddleware:
    async def __call__(self, request: Request, call_next):
        # Extract token from Authorization header
        token = request.headers.get("Authorization", "").replace("Bearer ", "")

        if not token:
            return JSONResponse(status_code=401, content={"detail": "Missing token"})

        # Validate token
        try:
            payload = jwt_service.validate_token(token)
            request.state.user_id = payload["sub"]
            request.state.permissions = payload.get("permissions", [])
        except JWTError:
            return JSONResponse(status_code=401, content={"detail": "Invalid token"})

        return await call_next(request)
```

### Integration Points for Rate Limiting

**Proposed Middleware Position**:
```
CORS → RateLimit → Authentication → Routes
```

**Rationale**:
- Rate limiting before auth protects authentication endpoints
- Prevents brute-force token attempts
- Reduces load on JWT validation
- Still allows CORS preflight requests

**Key Implementation Files**:
- `src/api/middleware/rate_limit.py` (new) - Rate limiting middleware
- `src/api/app.py:23` - Middleware registration
- `src/config/redis.py` (new) - Redis client configuration
- `tests/api/middleware/test_rate_limit.py` (new) - Test suite

### Rate Limiting Strategy Options

**Option 1: Fixed Window** (Simplest)
- Count requests per fixed time window (e.g., per minute)
- Redis key: `rate_limit:{ip}:{window_start}`
- Pros: Simple implementation, predictable behavior
- Cons: Burst traffic at window boundaries

**Option 2: Sliding Window Log** (Most accurate)
- Store timestamp of each request
- Redis sorted set per IP
- Pros: Smooth rate limiting, no boundary issues
- Cons: Higher Redis memory usage

**Option 3: Token Bucket** (Recommended)
- Allow burst traffic up to bucket capacity
- Refill tokens at steady rate
- Pros: Flexible, handles legitimate bursts
- Cons: Slightly more complex

### Redis Integration

**Current State**: No Redis in project

**Required Setup**:
1. Add redis dependency to `pyproject.toml`
2. Create Redis client with connection pooling
3. Configuration for Redis URL (env var)
4. Health check integration

**Configuration Needed**:
```python
# src/config/redis.py
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379")
RATE_LIMIT_REQUESTS = int(os.getenv("RATE_LIMIT_REQUESTS", "100"))
RATE_LIMIT_WINDOW = int(os.getenv("RATE_LIMIT_WINDOW", "60"))  # seconds
```

### Existing Patterns to Follow

**Middleware Pattern**: `src/api/middleware/auth.py`
- Async callable class
- Error handling with JSONResponse
- State injection via request.state
- Clean separation of concerns

**Configuration Pattern**: `src/config/database.py`
- Environment variables with defaults
- Connection pooling
- Graceful startup/shutdown
- Health checks

**Testing Pattern**: `tests/api/middleware/test_auth.py`
- Fixture for mock requests
- Test cases for success and failure paths
- Integration tests with FastAPI TestClient
- Async test support

## Code References

- `src/api/app.py:23-45` - FastAPI application setup and middleware registration
- `src/api/middleware/auth.py:15-67` - JWT authentication middleware implementation
- `src/auth/jwt.py:34-89` - Token validation logic
- `src/config/database.py:12-45` - Example configuration pattern
- `tests/api/middleware/test_auth.py:1-150` - Authentication test patterns

## Architecture Documentation

### Current Middleware Architecture

```
Request Flow:
1. Client → FastAPI
2. CORS Middleware (allow origins)
3. Authentication Middleware (JWT validation)
4. Route Handler (business logic)
5. Response → Client
```

### Proposed Architecture with Rate Limiting

```
Request Flow:
1. Client → FastAPI
2. CORS Middleware (allow origins)
3. Rate Limit Middleware (check/increment counters)
4. Authentication Middleware (JWT validation)
5. Route Handler (business logic)
6. Response → Client
```

## Open Questions

1. **Rate limit per IP or per user?**
   - IP-based: Protects auth endpoints before user identification
   - User-based: More accurate per-user limits after authentication
   - Recommendation: IP-based for auth endpoints, user-based for protected routes

2. **Rate limit configuration per endpoint?**
   - Different limits for login vs. API calls
   - Could use route metadata or decorator pattern
   - Need to decide on configuration approach

3. **Distributed rate limiting strategy?**
   - Single Redis instance sufficient for now
   - Future: Redis Cluster for horizontal scaling
   - Question: Expected scale and traffic patterns?

## Related Research

None found in thoughts/ directory. This is the first research document for rate limiting.

## Next Steps

1. Create implementation plan with three phases:
   - Phase 1: Redis setup and connection management
   - Phase 2: Rate limiting middleware implementation
   - Phase 3: Integration with existing auth flow
2. Decide on rate limiting strategy (recommend token bucket)
3. Define configuration approach for per-endpoint limits
