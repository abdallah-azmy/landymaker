
export default async function middleware(request) {
  const url = new URL(request.url);
  const host = request.headers.get('host') || '';
  
  // 1. Determine Context
  const isDirectBlog = host.includes('landymaker-blog.vercel.app');
  const isProxiedBlog = request.headers.get('x-blog-proxied') === '1';
  const isBlogContext = isDirectBlog || isProxiedBlog;

  // 2. Blog Context - Early Exit!
  // If we are already running on the Next.js blog project, let Next.js handle everything natively.
  if (isBlogContext) {
    return;
  }

  // 3. Blog & Next.js Assets Proxy Logic (Flutter Context)
  if (
    url.pathname.startsWith('/blog') || 
    url.pathname.startsWith('/_next') ||
    url.pathname === '/sitemap.xml' ||
    url.pathname === '/robots.txt' ||
    url.pathname === '/llms.txt'
  ) {
    // Rewrite to the blog project and inject a proxy header to break loops
    const newUrl = new URL(url.pathname, 'https://landymaker-blog.vercel.app');
    return new Response(null, {
      headers: {
        'x-middleware-rewrite': newUrl.toString(),
        'x-middleware-request-x-blog-proxied': '1'
      }
    });
  }

  // 4. Early Exit for Dashboard/Builder (Flutter Context)
  const pathSegments = url.pathname.split('/').filter(Boolean);
  if (pathSegments.length > 0 && ['login', 'register', 'dashboard', 'builder'].includes(pathSegments[0])) {
    // We are in Flutter Context. Mark it so vercel.json rewrites it to /index.html
    return new Response(null, {
      headers: {
        'x-middleware-next': '1',
        'x-middleware-request-x-is-flutter': '1'
      }
    });
  }

  const userAgent = request.headers.get('user-agent') || '';
  const botPattern = /bot|googlebot|crawler|spider|robot|crawling|ai|gptbot|perplexity|anthropic/i;
  const isBot = botPattern.test(userAgent);
  const slug = pathSegments.length > 0 ? pathSegments[0] : '/';

  if (isBot) {
    const SUPABASE_URL = process.env.SUPABASE_URL;
    const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

    try {
      // 1. Check PLATFORM SEO HANDLING (Super Admin Settings) first
      const routePath = slug === '/' ? '/' : `/${slug}`;
      const platformResponse = await fetch(
        `${SUPABASE_URL}/rest/v1/platform_seo_settings?route_path=eq.${routePath}&select=*`,
        {
          headers: {
            'apikey': SUPABASE_ANON_KEY,
            'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          },
        }
      );

      const settings = await platformResponse.json();
      
      // If we found custom SEO settings for this platform route
      if (settings && settings.length > 0) {
        const seo = settings[0];
        const title = seo.meta_title || "LandyMaker";
        const description = seo.meta_description || "LandyMaker Platform";
        const ogImage = seo.og_image_url || "https://landymaker.com/logo_social.webp";

        // Return semantic HTML for the bot representing the platform route
        return new Response(
          `<!DOCTYPE html>
          <html lang="ar">
            <head>
              <meta charset="UTF-8">
              <title>${title}</title>
              <meta name="description" content="${description}">
              <meta property="og:title" content="${title}">
              <meta property="og:description" content="${description}">
              <meta property="og:image" content="${ogImage}">
              <meta name="twitter:card" content="summary_large_image">
              <meta name="twitter:title" content="${title}">
              <meta name="twitter:description" content="${description}">
              <meta name="twitter:image" content="${ogImage}">
            </head>
            <body>
              <h1>${title}</h1>
              <p>${description}</p>
              <p>Welcome to LandyMaker, the ultimate landing page builder.</p>
            </body>
          </html>`,
          {
            headers: { 'content-type': 'text/html; charset=UTF-8' },
          }
        );
      }

      // 2. Check USER LANDING PAGE SEO HANDLING (Subdomains)
      if (slug !== '/') {
        const lpResponse = await fetch(
          `${SUPABASE_URL}/rest/v1/landing_pages?subdomain=eq.${slug}&select=*&is_published=eq.true`,
          {
            headers: {
              'apikey': SUPABASE_ANON_KEY,
              'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
            },
          }
        );

        const pages = await lpResponse.json();
        if (pages && pages.length > 0) {
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
      }
    } catch (e) {
      console.error("SEO Middleware Error:", e);
    }
  }

  // Real humans get the Flutter app - returning headers allows vercel.json to route to index.html
  return new Response(null, {
    headers: {
      'x-middleware-next': '1',
      'x-middleware-request-x-is-flutter': '1'
    }
  });
}

// Next.js (Vercel) automatically ignores /_next/ requests in middleware by default.
// We MUST explicitly tell it to run on EVERYTHING so we can proxy /_next/ to the blog.
export const config = {
  matcher: [
    '/:path*'
  ],
};
