# TypeScript Rules

## Strict mode — always

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}
```

## No `any` — use `unknown` + narrow

```ts
// Bad
function parse(input: any) {
  return input.value;
}

// Good
function parse(input: unknown) {
  if (typeof input === "object" && input !== null && "value" in input) {
    return (input as { value: string }).value;
  }
  throw new Error("Invalid input");
}
```

## No non-null assertions without comment

```ts
// Bad
const user = getUser()!;

// Good
const user = getUser();
if (!user) throw new Error("User not found");

// Acceptable when truly guaranteed
const el = document.getElementById("app")!; // guaranteed by HTML template
```

## Type external data as `unknown`

```ts
// Bad
const data = (await res.json()) as User;

// Good
const raw: unknown = await res.json();
const data = UserSchema.parse(raw); // Zod validates and infers
```

## Prefer `type` over `interface` for object shapes

Use `interface` only when you need declaration merging (e.g., extending third-party types).

```ts
type User = {
  id: string;
  email: string;
  createdAt: Date;
};
```

## Avoid type assertions — parse instead

```ts
// Bad
const config = JSON.parse(raw) as Config;

// Good
import { z } from "zod";
const Config = z.object({ apiUrl: z.string(), timeout: z.number() });
const config = Config.parse(JSON.parse(raw));
```

## Exhaustive switch statements

```ts
function assertNever(x: never): never {
  throw new Error(`Unhandled case: ${x}`);
}

switch (status) {
  case "active":
    return handleActive();
  case "inactive":
    return handleInactive();
  default:
    return assertNever(status); // compile error if new case added
}
```

## Never Do These

- `as any` — ever
- `@ts-ignore` without an explanatory comment on the same line
- Returning `any` from public functions
- Mutating function parameters
