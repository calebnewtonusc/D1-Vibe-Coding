# Naming Conventions

## Files and directories

| Type             | Convention                              | Example                  |
| ---------------- | --------------------------------------- | ------------------------ |
| React component  | `PascalCase.tsx`                        | `UserCard.tsx`           |
| Hook             | `use{Name}.ts`                          | `useScrollNav.ts`        |
| Utility          | `camelCase.ts`                          | `formatDate.ts`          |
| Constant         | `SCREAMING_SNAKE_CASE.ts`               | `API_ROUTES.ts`          |
| Types/interfaces | `PascalCase.ts`                         | `types.ts`               |
| API route        | `route.ts`                              | `app/api/users/route.ts` |
| Page             | `page.tsx`                              | `app/dashboard/page.tsx` |
| Server actions   | `actions.ts` or `{resource}.actions.ts` |                          |

## TypeScript identifiers

```ts
// Variables and functions: camelCase
const userProfile = getUser(id);

// Classes and types: PascalCase
type UserProfile = { id: string; email: string };

// Booleans: prefix with is/has/can/should
const isLoading = true;
const hasError = false;
const canEdit = user.role === "admin";

// Event handlers: prefix with handle
const handleSubmit = async (data: FormData) => {};
const handleKeyDown = (e: KeyboardEvent) => {};
```

## Database (Supabase/Postgres)

- Tables: `snake_case`, plural
- Columns: `snake_case`
- Indexes: `{table}_{column}_idx`
- Functions: `snake_case` verbs

## Git

- Branches: `feat/{slug}` | `fix/{slug}` | `chore/{desc}`
- Commits: `{type}: {description}` lowercase

## Environment variables

- All: `SCREAMING_SNAKE_CASE`
- Client-safe: `NEXT_PUBLIC_` prefix

## Anti-patterns

- No abbreviations: `usr` → `user`, `btn` → `button`, `cnt` → `count`
- No single-letter vars outside loops
- No vague names: `data`, `info`, `stuff`, `thing` — be specific
- No type suffix: `UserType` → `User`
