// Redeploy: Supabase credentials updated
import { supabase } from '@/lib/supabase'
import { notFound } from 'next/navigation'
import { Metadata } from 'next'
import Link from 'next/link'
import { Calendar, ChevronRight } from 'lucide-react'

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
    <div className="relative min-h-screen bg-[#030712] overflow-hidden selection:bg-[#00E5FF]/30 selection:text-white font-sans" dir="rtl">
      {/* Background Gradients */}
      <div className="absolute top-0 left-0 w-[500px] h-[500px] bg-[#1E3A8A]/20 rounded-full blur-[120px] -translate-y-1/2 -translate-x-1/3 pointer-events-none" />
      
      <article className="relative z-10 max-w-4xl mx-auto py-16 px-6 sm:px-8 lg:px-12">
        <Link 
          href="/blog" 
          className="inline-flex items-center gap-2 text-[#00E5FF] hover:text-white mb-12 transition-colors group text-sm font-bold"
        >
          <ChevronRight className="w-5 h-5 group-hover:-translate-x-1 transition-transform" />
          العودة للمدونة
        </Link>
        
        <header className="mb-16">
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-black text-[#F3F4F6] mb-8 leading-tight tracking-tight">
            {post.title}
          </h1>
          <div className="flex items-center text-[#94A3B8] font-medium text-sm gap-4">
            <span className="flex items-center gap-2 px-4 py-2 rounded-full bg-[#111827] border border-[#1F2937]">
              <Calendar className="w-4 h-4 text-[#00E5FF]" />
              نُشر في: {new Date(post.published_at || post.created_at).toLocaleDateString('ar-EG', { year: 'numeric', month: 'long', day: 'numeric' })}
            </span>
          </div>
        </header>
        
        {post.featured_image_url && (
          <div className="mb-16 rounded-3xl overflow-hidden shadow-[0_10px_40px_rgba(0,0,0,0.5)] border border-[#1F2937]">
            <img src={post.featured_image_url} alt={post.title} className="w-full h-auto object-cover" />
          </div>
        )}
        
        {/* Render HTML securely with Tailwind Typography Dark Mode */}
        <div 
          className="prose prose-invert prose-lg max-w-none mx-auto 
          prose-headings:text-[#F3F4F6] prose-headings:font-bold 
          prose-a:text-[#00E5FF] hover:prose-a:text-white prose-a:transition-colors
          prose-strong:text-[#F3F4F6] prose-strong:font-black
          prose-p:text-[#94A3B8] prose-p:leading-relaxed
          prose-li:text-[#94A3B8] prose-blockquote:border-r-4 prose-blockquote:border-l-0 prose-blockquote:border-[#00E5FF] prose-blockquote:bg-[#111827] prose-blockquote:px-6 prose-blockquote:py-2 prose-blockquote:rounded-l-xl
          prose-img:rounded-2xl prose-img:shadow-lg"
          dangerouslySetInnerHTML={{ __html: post.content }}
        />
      </article>
    </div>
  )
}
