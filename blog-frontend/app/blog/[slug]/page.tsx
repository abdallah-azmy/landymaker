import { supabase } from '@/lib/supabase'
import { notFound } from 'next/navigation'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
import { Metadata } from 'next'
import Link from 'next/link'

export const revalidate = 60

type Props = {
  params: Promise<{ slug: string }>
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const resolvedParams = await params
  const { data: post } = await supabase
    .from('blog_posts')
    .select('title, meta_title, meta_description, featured_image_url')
    .eq('slug', resolvedParams.slug)
    .single()

  if (!post) return { title: 'مقال غير موجود' }

  return {
    title: `${post.meta_title || post.title} | LandyMaker`,
    description: post.meta_description,
    openGraph: {
      title: post.meta_title || post.title,
      description: post.meta_description,
      images: post.featured_image_url ? [post.featured_image_url] : [],
    }
  }
}

export default async function BlogPost({ params }: Props) {
  const resolvedParams = await params
  const { data: post } = await supabase
    .from('blog_posts')
    .select('*')
    .eq('slug', resolvedParams.slug)
    .single()

  if (!post) {
    notFound()
  }

  return (
    <article className="max-w-3xl mx-auto py-16 px-4 sm:px-6 lg:px-8">
      <Link href="/blog" className="text-blue-600 hover:text-blue-800 mb-8 inline-flex items-center gap-2 transition-colors">
        <svg className="w-4 h-4 rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" /></svg>
        العودة للمدونة
      </Link>
      
      <header className="mb-12">
        <h1 className="text-4xl md:text-5xl font-extrabold text-gray-900 mb-6 leading-tight">{post.title}</h1>
        <div className="flex items-center text-gray-500 text-sm gap-4">
          <span className="flex items-center gap-1">
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
            نُشر في: {new Date(post.published_at || post.created_at).toLocaleDateString('ar-EG', { year: 'numeric', month: 'long', day: 'numeric' })}
          </span>
        </div>
      </header>
      
      {post.featured_image_url && (
        <div className="mb-12 rounded-2xl overflow-hidden shadow-lg">
          <img src={post.featured_image_url} alt={post.title} className="w-full h-auto object-cover" />
        </div>
      )}
      
      <div className="prose prose-lg prose-blue prose-slate max-w-none mx-auto prose-img:rounded-xl prose-headings:font-bold prose-a:text-blue-600 hover:prose-a:text-blue-800">
        <ReactMarkdown remarkPlugins={[remarkGfm]}>
          {post.content}
        </ReactMarkdown>
      </div>
    </article>
  )
}
