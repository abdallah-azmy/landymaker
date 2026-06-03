export const config = {
  matcher: [
    '/((?!api|_next/static|_next/image|favicon.png|manifest.json|icons).*)',
  ],
};

export default async function middleware(request) {
  const url = new URL(request.url);
  const userAgent = request.headers.get('user-agent') || '';
  const botPattern = /bot|googlebot|crawler|spider|robot|crawling|ai|gptbot|perplexity|anthropic/i;
  
  const isBot = botPattern.test(userAgent);
  const pathSegments = url.pathname.split('/').filter(Boolean);
  
  // Exclude dashboard and builder paths from SEO interception
  if (pathSegments.length > 0 && ['login', 'register', 'dashboard', 'builder'].includes(pathSegments[0])) {
    // Return undefined to pass through to Flutter SPA
    return;
  }

  const slug = pathSegments[0];

  if (isBot && slug) {
    const SUPABASE_URL = process.env.SUPABASE_URL;
    const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

    try {
      // Fetch page data from Supabase REST API
      const response = await fetch(
        `${SUPABASE_URL}/rest/v1/landing_pages?subdomain=eq.${slug}&select=*&is_published=eq.true`,
        {
          headers: {
            'apikey': SUPABASE_ANON_KEY,
            'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          },
        }
      );

      const pages = await response.json();
      if (pages.length > 0) {
        const page = pages[0];
        const design = typeof page.design_json === 'string' ? JSON.parse(page.design_json) : page.design_json;
        const blocks = design.blocks || [];
        const visibleBlocks = blocks.filter(b => b.is_visible !== false);

        const title = design.meta_title || `${slug} | LandyMaker`;
        const description = design.meta_description || "Created with LandyMaker - The Ultimate AI Landing Page Builder";

        // Generate semantic HTML5 content for bots from visible sections only
        const bodyContent = visibleBlocks.map(b => {
          if (b.type === 'hero') {
            return `<header><h1>${b.title || ''}</h1><p>${b.subtitle || b.description || ''}</p></header>`;
          }
          if (b.type === 'features' || b.type === 'faq') {
            return `<section><h2>${b.title || ''}</h2><p>${b.subtitle || b.description || ''}</p></section>`;
          }
          return '';
        }).join('');

        // Return lightweight semantic HTML for bots and AI crawlers
        return new Response(
          `<!DOCTYPE html>
          <html lang="ar">
            <head>
              <meta charset="UTF-8">
              <title>${title}</title>
              <meta name="description" content="${description}">
              <meta property="og:title" content="${title}">
              <meta property="og:description" content="${description}">
              <script type="application/ld+json">
              {
                "@context": "https://schema.org",
                "@type": "WebPage",
                "name": "${title}",
                "description": "${description}"
              }
              </script>
            </head>
            <body>
              <main>
                <article>
                  ${bodyContent}
                </article>
              </main>
              <footer>
                <p>Created on <a href="https://landymaker.com">LandyMaker</a></p>
              </footer>
            </body>
          </html>`,
          {
            headers: { 'content-type': 'text/html; charset=UTF-8' },
          }
        );
      }
    } catch (e) {
      console.error("SEO Middleware Error:", e);
    }
  }

  // Real humans get the Flutter app - returning undefined continues the request to index.html
  return;
}
