/// Base URL of the FastAPI backend (see skillbridge_backend/). No trailing slash.
///
/// Routers are mounted under the `/api/v1` prefix, so this constant carries the
/// prefix and every call site passes only the endpoint path.
///
/// Swap for a hosted backend when not running locally, e.g.
///   'https://glorious-train-69xqjqjw6q4vc54pq-8000.app.github.dev/api/v1'
const String kApiBaseUrl = 'http://127.0.0.1:8000/api/v1';
