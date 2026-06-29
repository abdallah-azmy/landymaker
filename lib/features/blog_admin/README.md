# Blog Admin Feature

Owns the blog post management system — CRUD for posts and categories from the dashboard.

## File Map

| Path | Role |
|------|------|
| `controllers/blog_cubit.dart` | `BlogCubit` — loads/saves/deletes blog posts and categories |
| `controllers/blog_state.dart` | `BlogState` — `BlogInitial`, `BlogLoading`, `BlogLoaded(posts, categories)`, `BlogError` |
| `data/models/blog_post_model.dart` | `BlogPostModel` — data class with `id`, `title`, `slug`, `content`, `isPublished`, timestamps, joined `BlogCategoryModel` |
| `data/models/blog_category_model.dart` | `BlogCategoryModel` — `id`, `name`, `slug` |
| `data/repositories/blog_repository.dart` | `BlogRepository` — raw Supabase queries for `blog_posts` and `blog_categories` tables; slug uniqueness enforcement |
| `screens/blog_management_screen.dart` | Main list screen — shows all posts with status badges, search, create FAB |
| `screens/blog_editor_screen.dart` | Post editor — title, slug, content, category, featured image, published toggle, SEO meta |

## State Management

- `BlogCubit` — single cubit for the whole feature. Emits `BlogLoaded(posts, categories)`.
- `BlogRepository` — injected via constructor, uses raw `SupabaseClient` (not `DatabaseService`).

## ⚠️ AI Warnings

- **Draft/publish lifecycle**: `BlogPostModel.isPublished` controls visibility. Draft posts are saved to the database but should not render on the public blog. Never auto-publish on save.
- **Slug enforcement**: `BlogRepository.savePost()` checks slug uniqueness server-side. Do NOT bypass this check — duplicate slugs cause routing conflicts.
- **BlogPostModel.toJson()** omits `id`, `createdAt`, and `category` (joined) for inserts — these are set by the DB. Only `updatedAt` is set client-side on updates.
- **BlogCubit emits `BlogError`** on failures, but does NOT surface them in the UI — the screens handle error display separately via `SnackBar`. Do not change this split.
