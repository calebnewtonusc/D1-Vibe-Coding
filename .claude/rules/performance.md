# Performance Rules

## Images — always use next/image

```tsx
import Image from "next/image";

<Image
  src="/hero.jpg"
  alt="Hero image"
  width={1200}
  height={600}
  priority // use for above-the-fold images
  className="rounded-2xl object-cover"
/>;
```

- Never `<img>` in Next.js
- Always set width/height — prevents layout shift
- Use `sizes` for responsive: `sizes="(max-width: 768px) 100vw, 50vw"`

## Fonts — always use next/font

```tsx
import { Inter } from "next/font/google";
const inter = Inter({ subsets: ["latin"], variable: "--font-inter" });
```

Never `<link href="fonts.googleapis.com/...">` in Next.js — bypasses optimization.

## Code splitting — dynamic imports

```tsx
import dynamic from "next/dynamic";

const HeavyChart = dynamic(() => import("@/components/HeavyChart"), {
  loading: () => <div className="animate-pulse bg-zinc-800 rounded-2xl h-64" />,
  ssr: false,
});
```

## Data fetching

Prefer Server Components — zero JS sent to client:

```ts
const data = await fetch(url, { next: { revalidate: 60 } }); // ISR
const data = await fetch(url, { cache: "no-store" }); // always fresh
```

React Query for client-side data that changes:

```ts
const { data } = useQuery({
  queryKey: ["posts", userId],
  queryFn: () => fetchPosts(userId),
  staleTime: 5 * 60 * 1000,
});
```

## Bundle size

Don't import entire libraries:

```ts
// Bad
import _ from "lodash";

// Good
import debounce from "lodash/debounce";

// Best — use native
const debounced = useCallback(debounce(fn, 300), []);
```

Flag any route over 150KB first load JS. Hard block at 250KB.

## Animation performance

Only animate `transform` and `opacity` — GPU-accelerated:

```tsx
whileHover={{ scale: 1.02 }}   // good — transform
whileHover={{ width: "110%" }} // bad — triggers layout recalc
```

## Never Do These

- Never block main thread with synchronous heavy computation — use Web Workers
- Never `useEffect` to fetch data that could be a Server Component
- Never `select("*")` from database — always specify columns
- Never fetch all rows without `.limit()` in production
