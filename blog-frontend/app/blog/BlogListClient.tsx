"use client";

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { useRouter, usePathname, useSearchParams } from 'next/navigation';
import { motion, AnimatePresence, Variants } from 'framer-motion';
import { Calendar, ChevronLeft, ChevronRight, Clock, TrendingUp, Search, Loader2 } from 'lucide-react';

export default function BlogListClient({ 
  posts, 
  currentPage, 
  totalPages,
  initialSearchQuery
}: { 
  posts: any[], 
  currentPage: number, 
  totalPages: number,
  initialSearchQuery: string 
}) {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  const [searchQuery, setSearchQuery] = useState(initialSearchQuery);
  const [isNavigating, setIsNavigating] = useState(false);

  // Debounce search input to avoid spamming the server
  useEffect(() => {
    const timer = setTimeout(() => {
      if (searchQuery !== initialSearchQuery) {
        setIsNavigating(true);
        const params = new URLSearchParams(searchParams);
        if (searchQuery) {
          params.set('q', searchQuery);
        } else {
          params.delete('q');
        }
        params.set('page', '1'); // Reset to first page on new search
        router.push(`${pathname}?${params.toString()}`);
      }
    }, 500);

    return () => clearTimeout(timer);
  }, [searchQuery, initialSearchQuery, pathname, router, searchParams]);

  // Turn off loading state when URL finishes updating
  useEffect(() => {
    setIsNavigating(false);
  }, [searchParams]);

  const handlePageChange = (newPage: number) => {
    setIsNavigating(true);
    const params = new URLSearchParams(searchParams);
    params.set('page', newPage.toString());
    router.push(`${pathname}?${params.toString()}`);
    
    // Smooth scroll to top
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const containerVariants: Variants = {
    hidden: { opacity: 0 },
    visible: { opacity: 1, transition: { staggerChildren: 0.1 } },
  };

  const itemVariants: Variants = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.5, ease: "easeOut" } },
    exit: { opacity: 0, scale: 0.95, transition: { duration: 0.2 } }
  };

  const getReadTime = (slug: string) => {
    const hash = slug.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
    return (hash % 5) + 2; 
  };

  return (
    <div className="relative min-h-screen bg-[#030712] overflow-hidden selection:bg-[#00E5FF]/30 selection:text-white font-sans" dir="rtl">
      
      {/* Background Gradients */}
      <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-[#1E3A8A]/20 rounded-full blur-[120px] -translate-y-1/2 translate-x-1/3 pointer-events-none" />
      <div className="absolute top-1/3 left-0 w-[400px] h-[400px] bg-[#00E5FF]/10 rounded-full blur-[100px] -translate-x-1/2 pointer-events-none" />

      {/* Navbar/Logo area */}
      <nav className="relative z-20 max-w-7xl mx-auto px-6 py-8 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <img src="https://landymaker.com/icons/Icon-192.png" alt="LandyMaker Logo" className="w-10 h-10 object-contain rounded-xl shadow-[0_0_15px_rgba(0,229,255,0.3)]" />
          <span className="text-2xl font-bold text-[#F3F4F6] tracking-wide">
            Landy<span className="text-[#00E5FF]">Maker</span>
          </span>
        </div>
      </nav>

      <div className="relative z-10 max-w-6xl mx-auto pb-24 pt-8 px-6 sm:px-8 lg:px-12">
        {/* Header Section */}
        <header className="mb-16 text-center max-w-3xl mx-auto">
          <motion.div 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, ease: "easeOut" }}
          >
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[#111827] text-[#00E5FF] font-medium text-sm mb-6 border border-[#1F2937] shadow-inner shadow-[#00E5FF]/5">
              <TrendingUp className="w-4 h-4" />
              <span>رؤى وأفكار</span>
            </div>
            <h1 className="text-4xl md:text-6xl font-black text-[#F3F4F6] mb-6 tracking-tight leading-tight">
              مساحتك للإلهام
              <br className="hidden md:block" />
              <span className="text-transparent bg-clip-text bg-gradient-to-l from-[#00E5FF] to-[#1E3A8A]">
                {" "}وتطوير أعمالك
              </span>
            </h1>
            <p className="text-lg md:text-xl text-[#94A3B8] leading-relaxed font-medium">
              استكشف أحدث المقالات والنصائح التي ستساعدك على زيادة مبيعاتك والوصول لمستوى جديد من النجاح.
            </p>
          </motion.div>

          {/* Search Bar */}
          <motion.div 
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.2, duration: 0.5 }}
            className="mt-10 max-w-lg mx-auto relative group"
          >
            <div className="absolute inset-y-0 right-0 pl-3 pr-4 flex items-center pointer-events-none">
              {isNavigating ? (
                <Loader2 className="h-5 w-5 text-[#00E5FF] animate-spin" />
              ) : (
                <Search className="h-5 w-5 text-[#64748B] group-focus-within:text-[#00E5FF] transition-colors" />
              )}
            </div>
            <input
              type="text"
              className="block w-full bg-[#111827] border border-[#1F2937] rounded-2xl py-4 pr-12 pl-4 text-[#F3F4F6] placeholder-[#64748B] focus:ring-2 focus:ring-[#00E5FF]/50 focus:border-[#00E5FF] transition-all outline-none shadow-lg"
              placeholder="ابحث عن مقالة..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </motion.div>
        </header>
        
        {/* Articles Grid */}
        <motion.div 
          variants={containerVariants}
          initial="hidden"
          animate="visible"
          className="grid gap-6 md:grid-cols-2 lg:grid-cols-3 relative"
        >
          {isNavigating && (
            <div className="absolute inset-0 bg-[#030712]/50 backdrop-blur-[2px] z-30 rounded-3xl transition-all duration-300 flex items-start justify-center pt-20">
              <Loader2 className="w-10 h-10 text-[#00E5FF] animate-spin" />
            </div>
          )}

          <AnimatePresence mode='popLayout'>
            {posts.map((post) => (
              <motion.article 
                key={post.slug} 
                layout
                variants={itemVariants}
                initial="hidden"
                animate="visible"
                exit="exit"
                className="group relative bg-[#111827] rounded-3xl p-8 border border-[#1F2937] hover:border-[#00E5FF]/30 hover:bg-[#1E293B] shadow-lg hover:shadow-[0_0_30px_rgba(0,229,255,0.1)] transition-all duration-300 flex flex-col h-full"
              >
                <div className="mb-6">
                  <span className="inline-block px-3 py-1 bg-[#1F2937] text-[#94A3B8] rounded-lg text-xs font-bold tracking-wide border border-[#1F2937]/50">
                    أعمال وتجارة
                  </span>
                </div>

                <Link href={`/blog/${post.slug}`} className="block mb-4 outline-none">
                  <h2 className="text-xl md:text-2xl font-bold text-[#F3F4F6] group-hover:text-[#00E5FF] transition-colors duration-300 leading-snug">
                    {post.title}
                  </h2>
                </Link>

                <p className="text-[#94A3B8] leading-relaxed mb-8 flex-grow line-clamp-3 text-sm md:text-base">
                  {post.meta_description || 'مقال شيق يحتوي على نصائح هامة للمهتمين بتطوير أعمالهم ومبيعاتهم.'}
                </p>

                <div className="flex items-center justify-between text-xs md:text-sm text-[#64748B] font-medium pt-6 border-t border-[#1F2937] mt-auto relative z-20">
                  <div className="flex items-center gap-4">
                    <div className="flex items-center gap-1.5">
                      <Calendar className="w-4 h-4 text-[#00E5FF]/70" />
                      <time dateTime={post.published_at}>
                        {new Date(post.published_at).toLocaleDateString('ar-EG', { month: 'short', day: 'numeric' })}
                      </time>
                    </div>
                    <div className="flex items-center gap-1.5">
                      <Clock className="w-4 h-4 text-[#00E5FF]/70" />
                      <span>{getReadTime(post.slug)} دقائق</span>
                    </div>
                  </div>

                  <div className="w-8 h-8 rounded-full bg-[#1F2937] flex items-center justify-center group-hover:bg-[#00E5FF] group-hover:text-[#030712] transition-colors duration-300">
                    <ChevronLeft className="w-4 h-4" />
                  </div>
                </div>

                <Link href={`/blog/${post.slug}`} className="absolute inset-0 z-10 rounded-3xl outline-none focus-visible:ring-2 focus-visible:ring-[#00E5FF]">
                  <span className="sr-only">قراءة المقال {post.title}</span>
                </Link>
              </motion.article>
            ))}
          </AnimatePresence>
        </motion.div>

        {/* Empty State */}
        {!isNavigating && posts.length === 0 && (
          <motion.div 
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="text-center py-24 bg-[#111827] rounded-3xl border border-dashed border-[#1F2937]"
          >
            <div className="w-20 h-20 bg-[#1F2937] rounded-full flex items-center justify-center mx-auto mb-6">
              <Search className="w-8 h-8 text-[#94A3B8]" />
            </div>
            <h3 className="text-2xl font-bold text-[#F3F4F6] mb-2">
              {initialSearchQuery ? 'لا توجد نتائج تطابق بحثك' : 'لا توجد مقالات بعد'}
            </h3>
            <p className="text-[#94A3B8] text-lg">
              {initialSearchQuery ? 'حاول استخدام كلمات مفتاحية مختلفة.' : 'نعمل على كتابة محتوى رائع لكم. عودوا قريباً!'}
            </p>
          </motion.div>
        )}

        {/* Pagination Controls */}
        {totalPages > 1 && (
          <div className="mt-16 flex items-center justify-center gap-4">
            <button
              onClick={() => handlePageChange(currentPage - 1)}
              disabled={currentPage === 1 || isNavigating}
              className="w-12 h-12 flex items-center justify-center rounded-2xl bg-[#111827] border border-[#1F2937] text-[#F3F4F6] hover:bg-[#1E293B] hover:border-[#00E5FF]/50 hover:text-[#00E5FF] disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-md"
              aria-label="الصفحة السابقة"
            >
              <ChevronRight className="w-5 h-5" />
            </button>
            
            <div className="flex items-center gap-2">
              {[...Array(totalPages)].map((_, i) => {
                const page = i + 1;
                const isActive = page === currentPage;
                // Show max 5 pages logic could go here if we had many pages, but for now showing all.
                return (
                  <button
                    key={page}
                    onClick={() => handlePageChange(page)}
                    disabled={isNavigating}
                    className={`w-12 h-12 flex items-center justify-center rounded-2xl font-bold transition-all ${
                      isActive 
                        ? 'bg-[#00E5FF] text-[#030712] shadow-[0_0_15px_rgba(0,229,255,0.4)]' 
                        : 'bg-[#111827] border border-[#1F2937] text-[#94A3B8] hover:bg-[#1E293B] hover:text-[#F3F4F6]'
                    }`}
                  >
                    {page}
                  </button>
                );
              })}
            </div>

            <button
              onClick={() => handlePageChange(currentPage + 1)}
              disabled={currentPage === totalPages || isNavigating}
              className="w-12 h-12 flex items-center justify-center rounded-2xl bg-[#111827] border border-[#1F2937] text-[#F3F4F6] hover:bg-[#1E293B] hover:border-[#00E5FF]/50 hover:text-[#00E5FF] disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-md"
              aria-label="الصفحة التالية"
            >
              <ChevronLeft className="w-5 h-5" />
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
