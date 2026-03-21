---
description: Scaffold a new project under projects/ with standard structure — full design system wired from day one
allowed-tools: Bash(mkdir:*), Bash(git:*), Bash(npm:*), Bash(npx:*), Bash(ls:*), Bash(cat:*), Bash(echo:*), Bash(printf:*), Read, Write, Edit, Glob
argument-hint: "<project-name> [description]"
---

# New Project

Scaffold `$ARGUMENTS` as a new project. Every project starts polished — never barebones.

## Step 1: Parse arguments

Split `$ARGUMENTS` into:

- `{name}`: first word (kebab-case)
- `{description}`: rest of the string, or empty

Ask the user what type of project:

1. **Next.js app** — full-stack web app (default for anything UI)
2. **Node.js API** — Fastify/Express backend, no frontend
3. **Python service** — FastAPI or script
4. **Library/package** — reusable TS/JS module
5. **Bare** — just README + git init

## Step 2: Create the directory and init git

```bash
mkdir -p projects/{name}
cd projects/{name}
git init
```

## Step 3: Scaffold by type

### Next.js app — full design system from day one

```bash
cd projects/{name}
npx create-next-app@latest . --typescript --tailwind --app --src-dir --import-alias "@/*" --no-git
npm install lucide-react framer-motion @tanstack/react-query zod react-hook-form @hookform/resolvers
npm install -D prettier prettier-plugin-tailwindcss
npx shadcn@latest init --defaults
npx shadcn@latest add button card input badge dialog sheet tabs skeleton toast dropdown-menu
```

Write `.prettierrc`:

```json
{
  "semi": true,
  "singleQuote": false,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100,
  "plugins": ["prettier-plugin-tailwindcss"]
}
```

Write `vercel.json`:

```json
{
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm install"
}
```

Write `.env.example`:

```bash
# Supabase (if using)
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

Write `src/app/globals.css` — dark base:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

html {
  scroll-behavior: smooth;
  background: #0a0a0a;
}
body {
  background: #0a0a0a;
  color: #f1f5f9;
  -webkit-font-smoothing: antialiased;
}
```

Write `src/components/navbar.tsx` — scroll-aware (mandatory):

```tsx
"use client";
import { useEffect, useState } from "react";

function useScrollNav() {
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    const handle = () => {
      const scrollY = window.scrollY;
      const nearBottom =
        scrollY + window.innerHeight >=
        document.documentElement.scrollHeight - 200;
      setVisible(scrollY > 80 && !nearBottom);
    };
    window.addEventListener("scroll", handle, { passive: true });
    return () => window.removeEventListener("scroll", handle);
  }, []);
  return visible;
}

export function Navbar() {
  const visible = useScrollNav();
  return (
    <nav
      className="fixed top-0 left-0 right-0 z-50 backdrop-blur-md bg-zinc-950/80 border-b border-zinc-800/50"
      style={{
        transform: visible ? "translateY(0)" : "translateY(-100%)",
        opacity: visible ? 1 : 0,
        transition: "transform 0.3s ease, opacity 0.3s ease",
      }}
    >
      <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
        <span className="font-semibold text-white text-sm">{name}</span>
      </div>
    </nav>
  );
}
```

Write `src/app/page.tsx` — real hero (no Lorem ipsum):

```tsx
import { Navbar } from "@/components/navbar";

export default function Home() {
  return (
    <main className="min-h-screen bg-[#0a0a0a]">
      <Navbar />
      <section className="min-h-screen flex items-center justify-center px-6">
        <div className="text-center max-w-3xl">
          <h1 className="text-5xl md:text-7xl font-bold tracking-tight text-white mb-6">
            {name}
          </h1>
          <p className="text-xl text-zinc-400 leading-relaxed">{description}</p>
        </div>
      </section>
    </main>
  );
}
```

### Node.js API

Create: `package.json`, `tsconfig.json` (strict, ES2022), `src/index.ts`, `.env.example`, `.gitignore`

### Python service

Create: `requirements.txt`, `main.py`, `.env.example`, `.gitignore`

### Library

Create: `package.json` (with `main`, `types`, `exports`), `tsconfig.json` (strict), `src/index.ts`

### Bare

Just: `README.md`, `.gitignore`

## Step 4: Initial commit

Stage by filename — never `git add .` or `git add -A`:

```bash
git add src/ .prettierrc package.json tsconfig.json .gitignore 2>/dev/null
git commit -m "init: {name} — {description or 'initial scaffold'}"
```

## Step 5: Create GitHub repo and push

```bash
GITHUB_USER=$(gh api user --jq .login)
gh repo create $GITHUB_USER/{name} --private --source=. --push
```

Report the GitHub URL and remind to connect to Vercel.

## Quality Check Before Finishing

- [ ] Tailwind dark mode configured (#0a0a0a background)
- [ ] shadcn/ui installed with core components
- [ ] Lucide React installed
- [ ] Framer Motion, React Query, Zod, React Hook Form installed
- [ ] Scroll-aware navbar present
- [ ] No Lorem ipsum anywhere
- [ ] prettier + prettier-plugin-tailwindcss configured
- [ ] vercel.json created
- [ ] .env.example created
- [ ] GitHub repo created and pushed (private)
