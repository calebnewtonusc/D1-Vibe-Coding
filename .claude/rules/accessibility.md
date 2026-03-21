# Accessibility Rules

## Semantic HTML first

```tsx
<nav aria-label="Main navigation">...</nav>
<header>, <main>, <footer>, <aside>, <section>
<h1>Page Title</h1>  // one per page
<h2>Section</h2>     // hierarchical

// Button = action. Link = navigation.
<button onClick={handleSubmit}>Submit</button>
<a href="/about">About</a>
```

## Focus styles — never remove

```tsx
<button
  className="focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:ring-offset-zinc-950"
  aria-label="Close dialog"
>
  <X className="w-4 h-4" />
</button>
```

Always replace `outline` with a visible custom focus ring. Never `outline-none` without a substitute.

## Images and icons

```tsx
<Image src="/hero.jpg" alt="Team working at whiteboard" />    // meaningful
<Image src="/wave.svg" alt="" />                               // decorative

// Icon-only button needs aria-label
<button aria-label="Delete post"><Trash2 className="w-4 h-4" /></button>

// Icon alongside text — hide from screen readers
<button>
  <Trash2 className="w-4 h-4" aria-hidden="true" />
  Delete post
</button>
```

## Forms

```tsx
<label htmlFor="email" className="text-sm text-zinc-400">Email</label>
<input
  id="email"
  type="email"
  autoComplete="email"
  aria-required="true"
  aria-describedby="email-error"
/>
{error && <p id="email-error" role="alert" className="text-sm text-red-400">{error}</p>}
```

## Color contrast (WCAG AA)

- Normal text: 4.5:1 minimum
- Large text (18px+ or 14px+ bold): 3:1
- UI components and icons: 3:1

The design system zinc/indigo palette meets these. Verify custom colors at webaim.org/resources/contrastchecker.

## Skip navigation

First child of body:

```tsx
<a
  href="#main-content"
  className="sr-only focus:not-sr-only focus:fixed focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:bg-indigo-600 focus:text-white focus:rounded-lg"
>
  Skip to main content
</a>
```

## Reduced motion

```tsx
import { useReducedMotion } from "framer-motion";

const shouldReduce = useReducedMotion();
<motion.div
  initial={shouldReduce ? {} : { opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
/>;
```

## Never Do These

- Never remove `outline` without a visible focus alternative
- Never rely solely on color to convey meaning
- Never autoplay video or audio
- Never `tabIndex` > 0
- Never build a modal without focus trapping
- Never use placeholder text as a label substitute
