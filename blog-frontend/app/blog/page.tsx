import { supabase } from '@/lib/supabase'
import Link from 'next/link'

export const revalidate = 60 // Revalidate every 60 seconds (ISR)

export default async function BlogIndex() {
  const { data: posts } = await supabase
    .from('blog_posts')
    .select('title, slug, meta_description, published_at')
    .eq('is_published', true)
    .order('published_at', { ascending: false })

  return (
    <div className="max-w-4xl mx-auto py-16 px-4 sm:px-6 lg:px-8">
      <header className="mb-12 text-center">
        <h1 className="text-4xl md:text-5xl font-extrabold text-gray-900 mb-4">مدونة LandyMaker</h1>
        <p className="text-lg text-gray-600">أحدث المقالات والنصائح لزيادة مبيعاتك وتطوير أعمالك</p>
      </header>
      
      <div className="grid gap-8">
        {posts?.map((post) => (
          <article key={post.slug} className="bg-white p-8 rounded-2xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
            <Link href={`/blog/${post.slug}`}>
              <h2 className="text-2xl font-bold text-blue-600 hover:text-blue-800 mb-3 transition-colors">{post.title}</h2>
            </Link>
            <p className="text-gray-600 mb-5 leading-relaxed">{post.meta_description}</p>
            <div className="text-sm text-gray-400 flex items-center gap-2">
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
              {new Date(post.published_at).toLocaleDateString('ar-EG', { year: 'numeric', month: 'long', day: 'numeric' })}
            </div>
          </article>
        ))}
        {(!posts || posts.length === 0) && (
          <div className="text-center py-20 bg-white rounded-2xl border border-gray-100">
            <p className="text-gray-500 text-lg">لا توجد مقالات منشورة حالياً. عد قريباً!</p>
          </div>
        )}
      </div>
    </div>
  )
}
