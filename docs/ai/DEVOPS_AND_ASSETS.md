# DevOps, CI/CD, and Asset Management - LandyMaker

This document covers how LandyMaker is built, deployed, and how assets/images are managed. Every AI assistant MUST read this before touching anything related to deployment, assets, icons, or secrets.

---

## 🖼️ 1. Unified Image Management & Media Picker System

LandyMaker features a centralized, robust Image Media Picker and Background Upload system used across the Builder Workspace:
- **Sources Supported**: 
  - **Local Device**: Uploads compress instantly using `image_picker` (max 1920x1920, 88% quality) to ensure lightweight assets before uploading.
  - **Pixabay API**: Search and paginate through free stock images. To comply with Pixabay ToS (no hotlinking), images are downloaded into memory (`Uint8List`) and instantly proxied/uploaded to ImgBB and Supabase. Supports advanced filtering (`photo`, `illustration`, `vector`). Safely handles Rate Limiting (429 HTTP status).
  - **Direct URL**: Users can paste an external URL.

### 📥 Double-Upload & Asset Importing
To ensure high performance and user ownership, LandyMaker employs a "Double-Upload" strategy for all external assets (Pixabay templates):
1. **ImgBB**: Primary host for the design's `image_url`. Optimized for global CDN delivery.
2. **Supabase Storage**: Secondary host used to "Import" the asset into the user's personal gallery.
3. **Workflow**: Triggered automatically via `importTemplateAssets` when applying templates or `magicReplaceImages` when using the Magic Swapper.

### ✨ Magic Image Swapper
A specialized engine in `LandingPageBuilderCubit` that bulk-replaces page visuals based on a search category.
- **Intelligent Categorization**: `Hero SaaS` uses `illustration`. `Testimonials/Team` uses `portrait`. Others use `photo`.
- **Async Safety**: Prevents saving the page if any `upload://` placeholders are active.

### 📊 Storage Quotas & Tier Enforcement
Image uploads to Supabase Storage are strictly governed by user tier:
- Free Tier: 50 images
- Pro Tier: 200 images
- Super Admin: Unlimited (999,999) images.

### 🚨 Strict Guidelines for Image Rendering (MUST FOLLOW)
- **Always use `CustomNetworkImage`**: Whenever you need to display an image from a URL, you **MUST** use `CustomNetworkImage`. Do **NOT** use `Image.network` or `CachedNetworkImage` directly. 
- **Why?**: `CustomNetworkImage` natively resolves the internal `upload://...` scheme showing real-time upload progress, handles network shimmer loading, and crucially sets memory bounds (`memCacheWidth` and `maxWidthDiskCache: 1200`) to prevent Out-Of-Memory (OOM) app crashes when displaying many images.

---

## 🚀 2. CI/CD Pipeline & Deployment Architecture (CRITICAL)

### Project Layout on Vercel
| Vercel Project | Project ID | URL | Source |
|---|---|---|---|
| `landymaker` | `prj_dDwATAOXwcnKLc7nh0wVRIqDjqjV` | `landymaker.com` | Main Flutter Web App |
| `landymaker-blog` | `prj_ONp0ZC8l6Udq8o13iXXjmAWWD7vc` | `landymaker-blog.vercel.app` | Next.js Blog (`blog-frontend/`) |

- **Main App**: Flutter Web app. Output directory is `build/web`.
- **Blog**: Next.js app in `blog-frontend/`. Auto-deploys via its own Vercel configuration.

### Main App (Flutter) CI/CD Pipeline
**⚠️ CRITICAL WARNING**: The `public/` and `/build/` directories are both in `.gitignore`. They are **NEVER committed to Git**.

**The ONLY correct way to deploy the main app** is via GitHub Actions (`.github/workflows/deploy.yml`):
1. Checkout code
2. Setup Node.js
3. Setup Flutter using subosito/flutter-action@v2
4. `flutter pub get`
5. `flutter build web --release --dart-define=...` (Output goes to `build/web/`)
6. Create `.vercel/project.json`
7. `npm install -g vercel@latest`
8. `vercel pull`
9. `vercel build --prod`
10. `vercel deploy --prebuilt --prod`

*Note: Disable Vercel Git auto-deploy for the main app to prevent race conditions.*

### Blog (Next.js) CI/CD Pipeline
Auto-deployed by Vercel directly when changes are pushed to `main`.
Output Directory: `.next`.

### Secrets & Environment Variables (CRITICAL)
1. **NEVER hardcode secrets**.
2. **NEVER commit `.env.local`**.
3. Flutter reads secrets via `--dart-define` at **build time**.
4. Edge middleware reads `process.env.*` from Vercel environment variables.

### App Icons & Assets
The project has **two sets** of icon/asset files. Both must be updated when changing the logo:
- `web/favicon.png`, `web/icons/Icon-*.png`, `web/logo_social.webp` (Copied to build by Flutter)
- `assets/images/logo.webp`, `assets/images/logo_small.webp` (Bundled inside Flutter app)

### Blog URL Routing & Middleware Precedence
The blog lives at `landymaker.com/blog/...` but is served from `landymaker-blog.vercel.app`.
Routing is handled by `middleware.js`.
**⚠️ CRITICAL MIDDLEWARE RULE**: The Blog & Next.js assets routing logic (`/blog` and `/_next`) **MUST** reside at the very top of `middleware.js` before static asset verification (`staticExtensions`).
**⚠️ vercel.json Rewrite Rule**: The default rewrite MUST exclude blog routes: `"source": "/((?!blog|_next|sitemap\\.xml|robots\\.txt|llms\\.txt).*)"`.

### Professional Error Handling & Fault Tolerance
1. **Edge Function Fallbacks**: If Pixabay API fails, fallback to static placeholders.
2. **Safe Color Parsing**: `LandingPageTheme.parseColor` includes a try-catch sanitize loop.
3. **Optimistic Asset Registration**: Image deduplication (SHA-256) is non-blocking.
