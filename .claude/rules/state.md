# State Management Rules

## State hierarchy — choose the lowest level that works

1. **Server state** (DB/API data) → React Query or SWR
2. **URL state** (filters, tabs, pagination) → `useSearchParams` / router
3. **Local component state** → `useState`
4. **Shared UI state** (modals, toasts, sidebar) → Zustand or React Context
5. **Form state** → React Hook Form
6. **Global app state** → Zustand (rarely needed)

## Server state — React Query

```ts
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";

const { data, isLoading, error } = useQuery({
  queryKey: ["posts", { userId, page }],
  queryFn: () => fetchPosts({ userId, page }),
  staleTime: 5 * 60 * 1000,
});

// Optimistic update
const queryClient = useQueryClient();
const { mutate: deletePost } = useMutation({
  mutationFn: (id: string) => api.delete(`/posts/${id}`),
  onMutate: async (id) => {
    await queryClient.cancelQueries({ queryKey: ["posts"] });
    const previous = queryClient.getQueryData(["posts"]);
    queryClient.setQueryData(["posts"], (old: Post[]) =>
      old.filter((p) => p.id !== id),
    );
    return { previous };
  },
  onError: (err, id, context) =>
    queryClient.setQueryData(["posts"], context?.previous),
  onSettled: () => queryClient.invalidateQueries({ queryKey: ["posts"] }),
});
```

## URL state — filters and pagination

```ts
const setFilter = (key: string, value: string) => {
  const params = new URLSearchParams(searchParams.toString());
  params.set(key, value);
  router.push(`?${params.toString()}`);
};
```

Use URL state for: tabs, sort order, filters, page number, search query — makes pages shareable.

## Shared UI state — Zustand

```ts
import { create } from "zustand";

export const useUIStore = create<UIStore>((set) => ({
  isSidebarOpen: false,
  openSidebar: () => set({ isSidebarOpen: true }),
  closeSidebar: () => set({ isSidebarOpen: false }),
}));
```

## Form state — React Hook Form + Zod

```ts
const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});
type FormData = z.infer<typeof schema>;

const {
  register,
  handleSubmit,
  formState: { errors, isSubmitting },
} = useForm<FormData>({ resolver: zodResolver(schema) });
```

## Loading/error/empty — all three required

```tsx
if (isLoading) return <Skeleton />;
if (error) return <ErrorMessage message={error.message} onRetry={refetch} />;
if (!data || data.length === 0) return <EmptyState />;
return <DataList data={data} />;
```

## Never Do These

- Never store server state in Zustand — use React Query
- Never use Context for high-frequency updates
- Never store derived values in state — compute with `useMemo`
- Never mutate state directly
- Never put async logic in useState setters
