# Security Rules

## Never hardcode secrets

```ts
// Bad
const client = new Anthropic({ apiKey: "sk-ant-..." });

// Good
const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
```

All secrets go in `.env` locally, in Vercel dashboard for production. `.env` must be in `.gitignore`.

## Validate all user input with Zod

```ts
const schema = z.object({
  userId: z.string().uuid(),
  content: z.string().min(1).max(10000),
});
const result = schema.safeParse(body);
if (!result.success) return 400;
```

Never trust `req.body` raw. Parse and validate before touching a database.

## Parameterized queries — never string interpolation

```ts
// Bad — SQL injection
const data = await db.query(`SELECT * FROM users WHERE id = '${userId}'`);

// Good — parameterized
const data = await db.query("SELECT * FROM users WHERE id = $1", [userId]);
```

## Auth checks before every sensitive operation

```ts
const {
  data: { user },
} = await supabase.auth.getUser();
if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

// Also check ownership — not just authentication
const post = await getPost(postId);
if (post.userId !== user.id) return 403;
```

## Never expose internal errors to the client

```ts
// Bad
return NextResponse.json({ error: err.stack }, { status: 500 });

// Good
console.error("[POST /api/posts]", err);
return NextResponse.json({ error: "Internal server error" }, { status: 500 });
```

## Content Security Policy

For `dangerouslySetInnerHTML` — only use with sanitized content:

```ts
import DOMPurify from "dompurify";
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userContent) }} />
```

## Pre-commit secret scan

```bash
git diff --cached | grep -E "^\+(sk-ant|sk-proj|ghp_|eyJhbGci|ANTHROPIC_API_KEY)" | grep -v "example\|placeholder\|process\.env"
```

Block any commit that surfaces real secrets.

## Never Do These

- Never log PII (emails, tokens, passwords) at any log level
- Never use `eval()` or `new Function()` with user-supplied strings
- Never trust user-supplied IDs without ownership verification
- Never disable HTTPS
- Never use MD5 for password hashing — use bcrypt or Argon2
