# Deployment Rules

## Default: Vercel

All Next.js projects deploy to Vercel.

```json
// vercel.json
{
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm install"
}
```

## Pre-deploy checklist

1. `npm run build` passes locally
2. `npm run lint` — zero warnings
3. No `.env` files staged in git
4. No `console.log` debug statements in critical paths
5. No hardcoded localhost URLs
6. No `TODO: fix before deploy` comments

## Environment variables

Set in Vercel dashboard — not hardcoded. Three environments:

- `Development` — local dev
- `Preview` — PRs and branch deploys
- `Production` — main branch only

Never put production secrets in Preview environments.

## Branch strategy

- `main` — always deployable
- Feature branches → Vercel preview deployments automatically
- Never merge to main without a passing preview deploy

## Always push to GitHub first

```bash
git push origin main
# Vercel auto-deploys from push
```

Never run `vercel --prod` from local for production.

## Post-deploy verification

1. Open production URL and verify it loads
2. Check Vercel dashboard for build errors
3. Test the primary user flow manually
4. Check Vercel Function logs for runtime errors

## Never Do These

- Never deploy from a dirty git working tree
- Never skip the local build check
- Never put secrets in `next.config.ts` `env` block (bundled into client JS)
