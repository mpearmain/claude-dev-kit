# API Rate Limiting Implementation Plan

**Date**: 2025-01-15
**Ticket**: None
**Related Research**: `example-research-convergence.md` (see examples/api-rate-limiting/)

## Overview

Implement Redis-backed rate limiting middleware for the FastAPI application using a token bucket algorithm. This will protect API endpoints from abuse and provide configurable limits per IP address.

## Current State Analysis

**Existing middleware stack**:
- CORS handling at `src/api/app.py:25`
- JWT authentication at `src/api/middleware/auth.py:15-67`
- No rate limiting present

**Technology constraints**:
- Python 3.11+ with FastAPI
- uv for dependency management
- No Redis currently in project
- Existing async middleware pattern to follow

**Key discoveries**:
- Auth middleware provides good pattern to follow (`src/api/middleware/auth.py`)
- Config pattern established in `src/config/database.py`
- Test patterns use pytest with FastAPI TestClient
- Middleware registration in `src/api/app.py:23-45`

## Desired End State

After completion:
1. Redis client configured with connection pooling
2. Rate limiting middleware protecting all endpoints
3. Configurable limits via environment variables
4. Token bucket algorithm allowing burst traffic
5. Comprehensive test coverage
6. Documentation updated

**Verification**:
- All tests pass: `uv run pytest tests/api/middleware/test_rate_limit.py`
- Manual testing shows 429 responses when rate limit exceeded
- Legitimate burst traffic handled smoothly
- Redis connection pooled and health-checked

## What We're NOT Doing

- Per-endpoint rate limit customization (future enhancement)
- User-based rate limiting (only IP-based for now)
- Rate limit analytics/monitoring dashboard
- Dynamic rate limit adjustment
- Distributed Redis cluster setup
- Whitelist/blacklist IP management

## Implementation Approach

**Strategy**: Implement in three independent phases, each fully tested before proceeding.

**Token bucket algorithm**: Allow burst traffic up to bucket capacity, refill tokens at steady rate.

**Redis key structure**: `rate_limit:{ip}:{endpoint}` storing `{tokens_remaining, last_refill_time}`

## Phase 1: Redis Client Setup

### Overview

Set up Redis connection with proper pooling, configuration, and health checks.

### Changes Required

#### 1. Dependency Management

**File**: `pyproject.toml`
**Changes**: Add Redis dependency

```toml
[project.dependencies]
redis = "^5.0.0"
```

#### 2. Redis Client Configuration

**File**: `src/config/redis.py` (new file)
**Changes**: Create Redis client with connection pooling

```python
import os
from redis.asyncio import ConnectionPool, Redis
from typing import Optional

class RedisConfig:
    """Redis configuration and client management."""

    def __init__(self):
        self.url = os.getenv("REDIS_URL", "redis://localhost:6379")
        self.max_connections = int(os.getenv("REDIS_MAX_CONNECTIONS", "10"))
        self.pool: Optional[ConnectionPool] = None
        self.client: Optional[Redis] = None

    async def connect(self) -> Redis:
        """Create Redis connection pool and client."""
        if not self.pool:
            self.pool = ConnectionPool.from_url(
                self.url,
                max_connections=self.max_connections,
                decode_responses=True
            )
            self.client = Redis(connection_pool=self.pool)
        return self.client

    async def disconnect(self):
        """Close Redis connection pool."""
        if self.pool:
            await self.pool.disconnect()
            self.pool = None
            self.client = None

    async def health_check(self) -> bool:
        """Check if Redis is accessible."""
        try:
            await self.client.ping()
            return True
        except Exception:
            return False


# Global instance
redis_config = RedisConfig()


async def get_redis() -> Redis:
    """Dependency for getting Redis client."""
    return await redis_config.connect()
```

#### 3. Application Lifecycle Integration

**File**: `src/api/app.py`
**Changes**: Add Redis startup/shutdown handlers

```python
from src.config.redis import redis_config

@app.on_event("startup")
async def startup():
    """Initialize connections on startup."""
    await redis_config.connect()
    logger.info("Redis connection pool initialized")

@app.on_event("shutdown")
async def shutdown():
    """Clean up connections on shutdown."""
    await redis_config.disconnect()
    logger.info("Redis connection pool closed")
```

#### 4. Health Check Endpoint

**File**: `src/api/routes/health.py`
**Changes**: Add Redis to health check

```python
from src.config.redis import redis_config

@router.get("/health")
async def health_check():
    """API health check including Redis."""
    redis_healthy = await redis_config.health_check()

    return {
        "status": "healthy" if redis_healthy else "degraded",
        "redis": "connected" if redis_healthy else "disconnected"
    }
```

#### 5. Environment Configuration

**File**: `.env.example` (new file)
**Changes**: Document required environment variables

```bash
# Redis Configuration
REDIS_URL=redis://localhost:6379
REDIS_MAX_CONNECTIONS=10
```

### Tests Required

**File**: `tests/config/test_redis.py` (new file)

```python
import pytest
from src.config.redis import RedisConfig

@pytest.mark.asyncio
async def test_redis_connection():
    """Test Redis connection establishment."""
    config = RedisConfig()
    client = await config.connect()
    assert client is not None
    assert await config.health_check() is True
    await config.disconnect()

@pytest.mark.asyncio
async def test_redis_ping():
    """Test Redis ping command."""
    config = RedisConfig()
    client = await config.connect()
    assert await client.ping() is True
    await config.disconnect()
```

### Success Criteria

#### Automated Verification:
- [ ] Tests pass: `uv run pytest tests/config/test_redis.py`
- [ ] Type checking passes: `uv run mypy src/config/redis.py`
- [ ] Linting passes: `uv run ruff check src/config/redis.py`
- [ ] Application starts without errors
- [ ] Health check endpoint returns Redis status

#### Manual Verification:
- [ ] Redis connection successful in development environment
- [ ] Health check shows "connected" when Redis running
- [ ] Health check shows "disconnected" when Redis stopped
- [ ] Connection pool limits respected (check Redis CLI: `INFO clients`)
- [ ] No connection leaks after repeated requests

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that Redis is properly configured before proceeding to Phase 2.

---

## Phase 2: Rate Limit Middleware

### Overview

Implement token bucket rate limiting middleware with Redis backend.

### Changes Required

#### 1. Rate Limit Configuration

**File**: `src/config/rate_limit.py` (new file)
**Changes**: Define rate limiting configuration

```python
import os
from dataclasses import dataclass

@dataclass
class RateLimitConfig:
    """Rate limiting configuration."""

    # Token bucket parameters
    capacity: int = int(os.getenv("RATE_LIMIT_CAPACITY", "100"))
    refill_rate: float = float(os.getenv("RATE_LIMIT_REFILL_RATE", "1.0"))  # tokens per second
    window_seconds: int = int(os.getenv("RATE_LIMIT_WINDOW", "60"))

    # Redis key TTL (cleanup old entries)
    ttl_seconds: int = window_seconds * 2


rate_limit_config = RateLimitConfig()
```

#### 2. Token Bucket Implementation

**File**: `src/api/middleware/rate_limit.py` (new file)
**Changes**: Implement token bucket algorithm

```python
import time
from fastapi import Request, Response
from fastapi.responses import JSONResponse
from src.config.redis import get_redis
from src.config.rate_limit import rate_limit_config

class RateLimitMiddleware:
    """Token bucket rate limiting middleware."""

    async def __call__(self, request: Request, call_next):
        """Check rate limit and process request."""
        # Get client IP
        client_ip = request.client.host

        # Skip rate limiting for health checks
        if request.url.path == "/health":
            return await call_next(request)

        # Check rate limit
        allowed = await self._check_rate_limit(client_ip)

        if not allowed:
            return JSONResponse(
                status_code=429,
                content={"detail": "Rate limit exceeded. Please try again later."},
                headers={"Retry-After": "60"}
            )

        response = await call_next(request)

        # Add rate limit headers
        remaining = await self._get_remaining_tokens(client_ip)
        response.headers["X-RateLimit-Limit"] = str(rate_limit_config.capacity)
        response.headers["X-RateLimit-Remaining"] = str(remaining)

        return response

    async def _check_rate_limit(self, client_ip: str) -> bool:
        """Check if request is within rate limit using token bucket."""
        redis = await get_redis()
        key = f"rate_limit:{client_ip}"
        now = time.time()

        # Get current bucket state
        bucket_data = await redis.hgetall(key)

        if not bucket_data:
            # First request - initialize bucket
            await redis.hset(key, mapping={
                "tokens": rate_limit_config.capacity - 1,
                "last_refill": now
            })
            await redis.expire(key, rate_limit_config.ttl_seconds)
            return True

        tokens = float(bucket_data["tokens"])
        last_refill = float(bucket_data["last_refill"])

        # Calculate token refill
        time_passed = now - last_refill
        new_tokens = min(
            rate_limit_config.capacity,
            tokens + (time_passed * rate_limit_config.refill_rate)
        )

        # Check if request allowed
        if new_tokens >= 1:
            # Allow request and consume token
            await redis.hset(key, mapping={
                "tokens": new_tokens - 1,
                "last_refill": now
            })
            await redis.expire(key, rate_limit_config.ttl_seconds)
            return True
        else:
            # Rate limit exceeded
            return False

    async def _get_remaining_tokens(self, client_ip: str) -> int:
        """Get remaining tokens for client."""
        redis = await get_redis()
        key = f"rate_limit:{client_ip}"
        bucket_data = await redis.hgetall(key)

        if not bucket_data:
            return rate_limit_config.capacity

        return int(float(bucket_data.get("tokens", 0)))
```

#### 3. Middleware Registration

**File**: `src/api/app.py`
**Changes**: Register rate limit middleware

```python
from src.api.middleware.rate_limit import RateLimitMiddleware

# Add after CORS, before authentication
app.add_middleware(RateLimitMiddleware)
```

#### 4. Environment Variables

**File**: `.env.example`
**Changes**: Add rate limit configuration

```bash
# Rate Limiting Configuration
RATE_LIMIT_CAPACITY=100        # Maximum tokens in bucket
RATE_LIMIT_REFILL_RATE=1.0    # Tokens per second
RATE_LIMIT_WINDOW=60           # Window in seconds
```

### Tests Required

**File**: `tests/api/middleware/test_rate_limit.py` (new file)

```python
import pytest
from fastapi.testclient import TestClient
from src.api.app import app

@pytest.fixture
def client():
    """Test client fixture."""
    return TestClient(app)

def test_rate_limit_allows_within_limit(client):
    """Test requests within rate limit are allowed."""
    for _ in range(10):
        response = client.get("/api/v1/users")
        assert response.status_code != 429

def test_rate_limit_blocks_excessive_requests(client):
    """Test excessive requests are rate limited."""
    # Make requests up to capacity
    for _ in range(100):
        response = client.get("/api/v1/users")

    # Next request should be rate limited
    response = client.get("/api/v1/users")
    assert response.status_code == 429
    assert "Retry-After" in response.headers

def test_rate_limit_headers_present(client):
    """Test rate limit headers are included."""
    response = client.get("/api/v1/users")
    assert "X-RateLimit-Limit" in response.headers
    assert "X-RateLimit-Remaining" in response.headers

def test_health_check_not_rate_limited(client):
    """Test health check endpoint bypasses rate limiting."""
    for _ in range(200):
        response = client.get("/health")
        assert response.status_code == 200
```

### Success Criteria

#### Automated Verification:
- [ ] Tests pass: `uv run pytest tests/api/middleware/test_rate_limit.py`
- [ ] Type checking passes: `uv run mypy src/api/middleware/rate_limit.py`
- [ ] Linting passes: `uv run ruff check src/api/middleware/`
- [ ] All existing tests still pass: `uv run pytest`

#### Manual Verification:
- [ ] Rate limiting works correctly (429 after exceeding limit)
- [ ] Rate limit headers present in responses
- [ ] Token bucket refills over time (burst traffic allowed)
- [ ] Health check not rate limited
- [ ] Multiple IPs tracked independently

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human before proceeding to Phase 3.

---

## Phase 3: Integration and Documentation

### Overview

Integrate with existing auth flow, add logging, and update documentation.

### Changes Required

#### 1. Logging Integration

**File**: `src/api/middleware/rate_limit.py`
**Changes**: Add structured logging

```python
import logging

logger = logging.getLogger(__name__)

class RateLimitMiddleware:
    async def __call__(self, request: Request, call_next):
        client_ip = request.client.host

        allowed = await self._check_rate_limit(client_ip)

        if not allowed:
            logger.warning(
                "Rate limit exceeded",
                extra={
                    "client_ip": client_ip,
                    "path": request.url.path,
                    "method": request.method
                }
            )
            return JSONResponse(...)

        return await call_next(request)
```

#### 2. API Documentation

**File**: `docs/api/rate-limiting.md` (new file)
**Changes**: Document rate limiting behavior

```markdown
# API Rate Limiting

## Overview
API requests are rate limited using a token bucket algorithm.

## Limits
- 100 requests per client IP
- Refills at 1 request per second
- Allows bursts up to bucket capacity

## Headers
- `X-RateLimit-Limit`: Maximum requests allowed
- `X-RateLimit-Remaining`: Requests remaining
- `Retry-After`: Seconds to wait when rate limited

## Response Codes
- `429 Too Many Requests`: Rate limit exceeded

## Exemptions
- Health check endpoint (`/health`)
```

#### 3. README Updates

**File**: `README.md`
**Changes**: Add rate limiting section

```markdown
## Rate Limiting

API requests are rate limited to prevent abuse. See [docs/api/rate-limiting.md](docs/api/rate-limiting.md) for details.

### Configuration

Set environment variables:
- `REDIS_URL`: Redis connection URL
- `RATE_LIMIT_CAPACITY`: Maximum bucket size (default: 100)
- `RATE_LIMIT_REFILL_RATE`: Tokens per second (default: 1.0)
```

#### 4. Docker Compose Update

**File**: `docker-compose.yml`
**Changes**: Add Redis service

```yaml
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
```

### Tests Required

**File**: `tests/integration/test_rate_limit_integration.py` (new file)

```python
@pytest.mark.asyncio
async def test_rate_limit_with_auth():
    """Test rate limiting works with authentication."""
    # Test that rate limiting occurs before auth
    # and auth is not invoked for rate-limited requests
    pass

@pytest.mark.asyncio
async def test_rate_limit_logging():
    """Test rate limit events are logged."""
    # Verify logging output
    pass
```

### Success Criteria

#### Automated Verification:
- [ ] All tests pass: `uv run pytest`
- [ ] Type checking passes: `uv run mypy src/`
- [ ] Linting passes: `uv run ruff check src/`
- [ ] Build succeeds: `uv build`
- [ ] Docker Compose starts successfully

#### Manual Verification:
- [ ] Documentation accurate and complete
- [ ] Rate limit logs appear in application logs
- [ ] Redis visible in Docker Compose setup
- [ ] Rate limiting works in Docker environment
- [ ] Performance acceptable (< 5ms overhead per request)

**Implementation Note**: This is the final phase. After completion and verification, the implementation is ready for PR and deployment.

---

## Testing Strategy

### Unit Tests
- Redis client connection and pooling
- Token bucket algorithm logic
- Rate limit middleware request handling
- Configuration parsing

### Integration Tests
- Rate limiting with authentication flow
- Multiple concurrent clients
- Token bucket refill over time
- Redis connection failures (graceful degradation)

### Manual Testing Steps
1. Start Redis: `docker-compose up redis`
2. Start API: `uv run uvicorn src.api.app:app`
3. Make rapid requests: `for i in {1..150}; do curl http://localhost:8000/api/v1/users; done`
4. Verify 429 responses after limit
5. Wait 60 seconds and verify requests allowed again
6. Check rate limit headers in responses
7. Stop Redis and verify graceful handling

## Performance Considerations

**Expected overhead**:
- Redis round-trip: ~1-2ms (local)
- Token calculation: < 1ms
- Total: < 5ms per request

**Optimization opportunities** (future):
- Local cache for rate limit state (trade consistency for speed)
- Batch Redis operations for multiple requests
- Redis pipeline for atomic operations

## Migration Notes

Not applicable - new feature, no existing data.

## References

- Original research: `example-research-convergence.md` (this examples directory)
- Authentication middleware pattern: `src/api/middleware/auth.py`
- Configuration pattern: `src/config/database.py`
- Token bucket algorithm: https://en.wikipedia.org/wiki/Token_bucket
