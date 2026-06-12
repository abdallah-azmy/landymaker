# LandyMaker Blog (Next.js)

Headless blog for the LandyMaker platform, proxied under `landymaker.com/blog/...` via Vercel Edge Middleware.

## Tech Stack

- **Framework**: Next.js 16 (App Router)
- **Backend**: Supabase (PostgreSQL) — `blog_posts` table
- **Hosting**: Vercel (`landymaker-blog` project, auto-deployed from `blog-frontend/`)

## Project Structure

```
blog-frontend/
├── app/
│   ├── blog/
│   │   ├── page.tsx            # Blog listing page
│   │   ├── BlogListClient.tsx  # Client-side blog list component
│   │   └── [slug]/page.tsx     # Individual blog post page (force-dynamic)
│   ├── layout.tsx               # Root layout with Geist font
│   ├── page.tsx                 # Homepage (redirect or placeholder)
│   ├── robots.ts                # Dynamic robots.txt
│   └── sitemap.ts               # Dynamic sitemap.xml
├── lib/
│   └── supabase.ts              # Supabase client (reads from NEXT_PUBLIC_* env vars)
└── public/
```

## Critical Configurations

- Environment variables must be set in Vercel Dashboard for `landymaker-blog`:
  - `NEXT_PUBLIC_SUPABASE_URL`
  - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- Individual blog post pages use `export const dynamic = 'force-dynamic'` with `revalidate = 0` to prevent 404 caching.
- Routing is handled by `middleware.js` in the root project — do NOT add `/blog` as a Flutter route.

## Local Development

```bash
cd blog-frontend
npm install
npm run dev
```

The blog runs on `localhost:3000` independently from the Flutter app.

## Deployment

Auto-deployed by Vercel on pushes to `main`. No manual deploy steps needed.
