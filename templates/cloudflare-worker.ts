/**
 * Cloudflare Worker + D1 Template
 *
 * Drop-in starter for a Workers API with D1 database.
 * Includes: CORS, error handling, typed env, JSON helpers.
 *
 * Usage:
 *   1. Copy to src/index.ts in your Worker project
 *   2. Update the Env interface with your bindings
 *   3. Add your routes in the fetch handler
 */

interface Env {
  DB: D1Database;
  ENVIRONMENT: string;
}

function json<T>(data: T, status = 200): Response {
  return new Response(JSON.stringify({ data }), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function jsonError(message: string, status = 500): Response {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

function withCors(response: Response): Response {
  const headers = new Headers(response.headers);
  for (const [key, value] of Object.entries(CORS_HEADERS)) {
    headers.set(key, value);
  }
  return new Response(response.body, {
    status: response.status,
    headers,
  });
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: CORS_HEADERS });
    }

    const url = new URL(request.url);
    const { pathname } = url;
    const method = request.method;

    try {
      // Health check
      if (pathname === "/health") {
        const result = await env.DB.prepare("SELECT 1 as ok").first<{
          ok: number;
        }>();
        return withCors(
          json({
            status: "healthy",
            database: result?.ok === 1 ? "connected" : "error",
            timestamp: new Date().toISOString(),
          }),
        );
      }

      // Add your routes here:
      // if (pathname === "/api/items" && method === "GET") { ... }

      // 404 fallback
      return withCors(jsonError("Not found", 404));
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "Internal server error";
      console.error("[Worker Error]", err);
      return withCors(jsonError(message, 500));
    }
  },
} satisfies ExportedHandler<Env>;
