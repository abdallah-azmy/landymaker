export default async function handler(req, res) {
  const SUPABASE_URL = process.env.SUPABASE_URL;
  const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

  if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
    return res.status(500).json({ error: 'Missing Supabase Config' });
  }

  try {
    // Fetch all published public landing pages
    const responsePages = await fetch(
      `${SUPABASE_URL}/rest/v1/landing_pages?select=subdomain,updated_at&is_published=eq.true`,
      {
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        },
      }
    );
    const pages = await responsePages.json();

    // Fetch all published blog posts
    const responseBlogs = await fetch(
      `${SUPABASE_URL}/rest/v1/blog_posts?select=slug,updated_at&is_published=eq.true`,
      {
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        },
      }
    );
    const blogs = await responseBlogs.json();
    
    // Core Platform URLs
    const staticUrls = [
      { loc: 'https://landymaker.com/', priority: 1.0, changefreq: 'weekly' },
      { loc: 'https://landymaker.com/builder', priority: 0.8, changefreq: 'monthly' },
      { loc: 'https://landymaker.com/blog', priority: 0.9, changefreq: 'daily' },
      // Programmatic Pages (will be added later in Phase 3)
      { loc: 'https://landymaker.com/landing-page-builder-for-saas', priority: 0.9, changefreq: 'monthly' },
    ];

    // Map user generated landing pages
    const dynamicLandingUrls = (pages || []).map(page => ({
      loc: `https://landymaker.com/${page.subdomain}`,
      lastmod: new Date(page.updated_at).toISOString().split('T')[0],
      priority: 0.7,
      changefreq: 'weekly'
    }));

    // Map blog posts
    const dynamicBlogUrls = (blogs || []).map(blog => ({
      loc: `https://landymaker.com/blog/${blog.slug}`,
      lastmod: new Date(blog.updated_at).toISOString().split('T')[0],
      priority: 0.8,
      changefreq: 'weekly'
    }));

    const allUrls = [...staticUrls, ...dynamicLandingUrls, ...dynamicBlogUrls];

    const sitemapXml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  ${allUrls.map(url => `
  <url>
    <loc>${url.loc}</loc>
    ${url.lastmod ? `<lastmod>${url.lastmod}</lastmod>` : ''}
    <changefreq>${url.changefreq}</changefreq>
    <priority>${url.priority}</priority>
  </url>
  `).join('')}
</urlset>`;

    res.setHeader('Content-Type', 'text/xml');
    res.setHeader('Cache-Control', 's-maxage=86400, stale-while-revalidate'); // Cache for 1 day at Edge
    res.status(200).send(sitemapXml);
  } catch (error) {
    console.error('Sitemap generation error:', error);
    res.status(500).end();
  }
}
