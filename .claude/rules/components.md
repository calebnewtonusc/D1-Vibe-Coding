# Component Rules

## shadcn/ui first — never build primitives from scratch

Before writing any UI component:

```bash
npx shadcn@latest add button dialog input select card toast dropdown-menu tabs badge skeleton
```

Only build custom if shadcn doesn't have it.

## Component file structure

```ts
// 1. Imports
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Loader2 } from "lucide-react";

// 2. Types
interface UserCardProps {
  user: User;
  onEdit?: (id: string) => void;
}

// 3. Component
export function UserCard({ user, onEdit }: UserCardProps) {
  const [isExpanded, setIsExpanded] = useState(false);
  const displayName = `${user.firstName} ${user.lastName}`;
  const handleEdit = () => onEdit?.(user.id);
  if (!user) return null;
  return <div className="bg-zinc-900 border border-zinc-800 rounded-2xl p-6">...</div>;
}
```

## Skeleton loaders — required for every async component

```tsx
export function UserCardSkeleton() {
  return (
    <div className="bg-zinc-900 border border-zinc-800 rounded-2xl p-6 animate-pulse">
      <div className="h-4 bg-zinc-800 rounded w-3/4 mb-3" />
      <div className="h-3 bg-zinc-800 rounded w-1/2" />
    </div>
  );
}
```

## Empty states — required for every list component

```tsx
export function EmptyState({ title, description, action }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-20 text-center">
      <div className="p-4 bg-zinc-800/50 rounded-2xl mb-4">
        <InboxIcon className="w-8 h-8 text-zinc-500" />
      </div>
      <h3 className="text-lg font-semibold text-zinc-200 mb-2">{title}</h3>
      <p className="text-zinc-500 text-sm max-w-sm mb-6">{description}</p>
      {action && <Button onClick={action.onClick}>{action.label}</Button>}
    </div>
  );
}
```

## Error states

```tsx
export function ErrorMessage({
  message,
  onRetry,
}: {
  message: string;
  onRetry?: () => void;
}) {
  return (
    <div className="flex flex-col items-center justify-center py-12 text-center">
      <div className="p-3 bg-red-500/10 rounded-xl mb-4">
        <AlertCircle className="w-6 h-6 text-red-400" />
      </div>
      <p className="text-zinc-400 text-sm mb-4">{message}</p>
      {onRetry && (
        <Button variant="outline" onClick={onRetry} size="sm">
          Try again
        </Button>
      )}
    </div>
  );
}
```

## Icons — Lucide React only

```tsx
import { Loader2, Zap } from "lucide-react";

<Loader2 className="w-4 h-4 animate-spin" />

// Feature icon with colored bubble
<div className="p-2.5 bg-indigo-500/10 rounded-xl">
  <Zap className="w-5 h-5 text-indigo-400" />
</div>
```

## Never Do These

- Never build custom button, input, dialog, select, dropdown — use shadcn/ui
- Never use inline styles — Tailwind only
- Never render `null` on error — show an error state
- Never render nothing on empty — show an empty state
- Never forget loading state on async components
