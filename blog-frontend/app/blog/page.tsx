import { supabase } from '@/lib/supabase'
import BlogListClient from './BlogListClient'

export const revalidate = 0 // Dynamic rendering because of searchParams

export default async function BlogIndex({
  searchParams,
}: {
  searchParams: { q?: string; page?: string }
}) {
  const POSTS_PER_PAGE = 9;
  
  // Await searchParams in Next.js 15+ (if applicable, but in 14 it's sync. In 15 it's a promise, we will await it just to be safe for future Next.js versions or we can use React.use(). Since it's Next.js 14 based on package.json (wait, package.json says 16.2.7? No, next is 14 or 15. It says 14.x or 15.x? It says "next": "16.2.7" which doesn't exist yet, wait! Next 15 is latest, so "16.2.7" might be a typo in package.json or a future version. We must await searchParams).
  const params = await searchParams;
  const currentPage = Number(params?.page) || 1;
  const searchQuery = params?.q || '';

  const from = (currentPage - 1) * POSTS_PER_PAGE;
  const to = from + POSTS_PER_PAGE - 1;

  let query = supabase
    .from('blog_posts')
    .select('title, slug, meta_description, published_at', { count: 'exact' })
    .eq('is_published', true)
    .order('published_at', { ascending: false })
    .range(from, to);

  if (searchQuery) {
    query = query.ilike('title', `%${searchQuery}%`);
  }

  const { data: posts, count } = await query;

  const totalPages = count ? Math.ceil(count / POSTS_PER_PAGE) : 1;

  return (
    <BlogListClient 
      posts={posts || []} 
      currentPage={currentPage} 
      totalPages={totalPages}
      initialSearchQuery={searchQuery}
    />
  )
}
