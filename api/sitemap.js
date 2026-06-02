export default async function handler(req, res) {
  const SUPABASE_URL = process.env.SUPABASE_URL;
  const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

  if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
    return res.status(500).json({ error: 'Missing Supabase Config' });
  }

  try {
    // Fetch all published public landing pages
    const response = await fetch(
      `${SUPABASE_URL}/rest/v1/landing_pages?select=subdomain,updated_at&is_published=eq.true`,
      {
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        },
      }
    );

    const pages = await response.json();
    
    // Core Platform URLs
    const staticUrls = [
      { loc: 'https://www.landymaker.com/', priority: 1.0, changefreq: 'weekly' },
      { loc: 'https://www.landymaker.com/builder', priority: 0.8, changefreq: 'monthly' },
      // Programmatic Pages (will be added later in Phase 3)
      { loc: 'https://www.landymaker.com/landing-page-builder-for-saas', priority: 0.9, changefreq: 'monthly' },
    ];

    // Map user generated pages
    const dynamicUrls = (pages || []).map(page => ({
      loc: `https://www.landymaker.com/${page.subdomain}`,
      lastmod: new Date(page.updated_at).toISOString().split('T')[0],
      priority: 0.7,
      changefreq: 'weekly'
    }));

    const allUrls = [...staticUrls, ...dynamicUrls];

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
