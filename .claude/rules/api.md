# API Rules

## Next.js App Router structure

```ts
// app/api/{resource}/route.ts
import { NextRequest, NextResponse } from "next/server";

export async function GET(req: NextRequest) {
  try {
    // logic
    return NextResponse.json({ data }, { status: 200 });
  } catch (err) {
    console.error("[GET /api/resource]", err);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 },
    );
  }
}
```

## Always validate with Zod

```ts
import { z } from "zod";

const schema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
});

const body = schema.safeParse(await req.json());
if (!body.success) {
  return NextResponse.json({ error: body.error.flatten() }, { status: 400 });
}
```

## Consistent response shapes

```ts
// Success
{ data: T, meta?: { total, page, perPage } }

// Error
{ error: string, details?: unknown }
```

## HTTP status codes

| Code | Use case                      |
| ---- | ----------------------------- |
| 200  | GET/PATCH success             |
| 201  | POST that creates a resource  |
| 204  | DELETE success                |
| 400  | Validation failure            |
| 401  | Not authenticated             |
| 403  | Authenticated but not allowed |
| 404  | Not found                     |
| 409  | Conflict / duplicate          |
| 500  | Internal server error         |

## Anthropic API

```ts
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

const message = await client.messages.create({
  model: "claude-sonnet-4-6", // default
  // "claude-haiku-4-5-20251001" — fast/cheap
  // "claude-opus-4-6"           — best
  max_tokens: 1024,
  messages: [{ role: "user", content: prompt }],
});
```

Streaming:

```ts
const stream = await client.messages.stream({ model: "claude-sonnet-4-6", ... });
return new Response(stream.toReadableStream(), {
  headers: { "Content-Type": "text/event-stream", "Cache-Control": "no-cache" },
});
```

## Never Do These

- Never expose internal error stack traces in production responses
- Never log raw request bodies containing passwords or tokens
- Never use `any` type in route handlers
- Never skip validation on user-provided input
- Never hardcode secrets — always `process.env.VAR_NAME`
