
/**
 * ======================================================
 * SYSTEM: Vercel Edge Middleware
 * PURPOSE: SEO, Routing, and Multi-tenant Proxy
 * USED BY: Vercel Deployment
 * DEPENDENCIES:
 * - Supabase REST API (for SEO Metadata)
 * - landymaker-blog (for blog proxying)
 * ======================================================
 */

export default async function middleware(request) {
  const url = new URL(request.url);
  const host = request.headers.get('host') || '';
  const cleanHost = host.split(':')[0].toLowerCase();

  // 1. Determine Blog Context & Handle Proxied Requests
  const isDirectBlog = cleanHost.includes('landymaker-blog.vercel.app');
  const isProxiedBlog = request.headers.get('x-blog-proxied') === '1';
  const isBlogContext = isDirectBlog || isProxiedBlog;

  // Blog Context - Early Exit!
  if (isBlogContext) {
    return;
  }

  const isCoreDomain = cleanHost === 'landymaker.com' ||
                       cleanHost === 'landymaker.vercel.app' ||
                       cleanHost === 'localhost' ||
                       cleanHost === '127.0.0.1' ||
                       cleanHost.startsWith('dashboard.') ||
                       cleanHost.startsWith('app.');

  // 2. Blog & Next.js Assets Proxy Logic (Core Domain Context Only) - MUST BE FIRST
  // This must execute before static assets early-exit to avoid 404s on Next.js bundle files (_next/static/...)
  if (isCoreDomain) {
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
  } else {
    // 4. Custom Domain Context - Dynamic Robots.txt and Sitemap.xml
    if (url.pathname === '/robots.txt') {
      return new Response(
        `User-agent: *\nAllow: /\nSitemap: https://${cleanHost}/sitemap.xml`,
        {
          headers: { 'content-type': 'text/plain; charset=UTF-8' }
        }
      );
    }

    if (url.pathname === '/sitemap.xml') {
      const SUPABASE_URL = process.env.SUPABASE_URL;
      const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

      try {
        const response = await fetch(
          `${SUPABASE_URL}/rest/v1/landing_pages?custom_domain=eq.${cleanHost}&select=updated_at,is_published`,
          {
            headers: {
              'apikey': SUPABASE_ANON_KEY,
              'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
            },
          }
        );
        const pages = await response.json();
        if (pages && pages.length > 0 && pages[0].is_published) {
          const updatedAt = pages[0].updated_at ? new Date(pages[0].updated_at).toISOString() : new Date().toISOString();
          const sitemapXml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://${cleanHost}/</loc>
    <lastmod>${updatedAt}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>`;
          return new Response(sitemapXml, {
            headers: { 'content-type': 'application/xml; charset=UTF-8' }
          });
        }
      } catch (err) {
        console.error("Sitemap Generation Error:", err);
      }
      return new Response('Not Found', { status: 404 });
    }
  }

  // 5. Early Exit for Static Assets (Ignore bots check for efficiency)
  const staticExtensions = /\.(js|wasm|png|jpg|jpeg|gif|svg|ico|json|css|woff2?|ttf|eot|mp4|webm|mp3|wav|ogg|pdf|txt|xml)$/i;
  if (staticExtensions.test(url.pathname)) {
    return;
  }

  // 6. Early Exit for Core Platform Routes (Dashboard/Builder/Auth)
  const pathSegments = url.pathname.split('/').filter(Boolean);
  if (isCoreDomain && pathSegments.length > 0 && ['login', 'register', 'dashboard', 'builder'].includes(pathSegments[0])) {
    return;
  }

  // 7. Bot & Crawler SEO Interception
  const userAgent = request.headers.get('user-agent') || '';
  const botPattern = /bot|googlebot|crawler|spider|robot|crawling|ai|gptbot|perplexity|anthropic/i;
  const isBot = botPattern.test(userAgent);

  if (isBot) {
    const SUPABASE_URL = process.env.SUPABASE_URL;
    const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

    try {
      let tenant = null;
      let isCustom = false;

      if (isCoreDomain) {
        const slug = pathSegments.length > 0 ? pathSegments[0] : '/';
        const reservedPaths = new Set([
          'blog', '_next', 'login', 'register', 'signup', 'signin',
          'forgot-password', 'reset-password', 'dashboard', 'admin',
          'settings', 'profile', 'pricing', 'plans', 'billing', 'checkout',
          'success', 'cancel', 'api', 'auth', 'app', 'editor', 'builder',
          'pages', 'page', 'store', 'products', 'orders', 'analytics',
          'support', 'help', 'about', 'contact', 'privacy', 'terms',
          'sitemap', 'robots.txt', 'favicon.ico', 'home', 'public_viewer',
          'assets', 'images', 'icons', 'web'
        ]);

        if (slug === '/' || reservedPaths.has(slug)) {
          // Platform route (e.g. root or page within the main application)
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
          if (settings && settings.length > 0) {
            const seo = settings[0];
            const title = seo.meta_title || "LandyMaker";
            const description = seo.meta_description || "LandyMaker Platform";
            const ogImage = seo.og_image_url || "https://landymaker.com/logo_social.webp";

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
          return;
        } else {
          // Path-based slug (e.g. landymaker.com/azmy)
          tenant = slug;
          isCustom = false;
        }
      } else {
        // Custom Domain (e.g. customdomain.com)
        tenant = cleanHost;
        isCustom = true;
      }

      if (tenant) {
        const queryParam = isCustom ? `custom_domain=eq.${tenant}` : `subdomain=eq.${tenant}`;
        const lpResponse = await fetch(
          `${SUPABASE_URL}/rest/v1/landing_pages?${queryParam}&select=*,profiles(tier)&is_published=eq.true`,
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
          
          // Verify billing tier permissions for custom domains
          const tier = page.profiles?.tier || 'free';
          if (isCustom && tier === 'free') {
            return new Response('Not Found', { status: 404 });
          }

          const design = typeof page.design_json === 'string' ? JSON.parse(page.design_json) : page.design_json;
          const blocks = design.blocks || [];
          const visibleBlocks = blocks.filter(b => b.is_visible !== false);

          const title = design.meta_title || `${page.subdomain || tenant} | LandyMaker`;
          const description = design.meta_description || "Created with LandyMaker - The Ultimate AI Landing Page Builder";
          const ogImage = design.og_image_url || "https://landymaker.com/logo_social.webp";
          const fbPixelId = design.fb_pixel_id || '';
          const tiktokPixelId = design.tiktok_pixel_id || '';
          const snapPixelId = design.snap_pixel_id || '';

          // Parse and render semantic HTML for all blocks
          const bodyContent = visibleBlocks.map(b => {
            const blockTitle = b.title || '';
            const blockSub = b.subtitle || b.description || '';
            
            switch (b.type) {
              case 'logo_header':
                return `<header><h1>${blockTitle || 'LandyMaker Page'}</h1></header>`;
              case 'hero':
              case 'hero_saas':
                return `<header><h1>${blockTitle}</h1><p>${blockSub}</p>${b.button_text ? `<button>${b.button_text}</button>` : ''}</header>`;
              case 'features': {
                const listItems = (b.items || []).map(item => `<li><h3>${item.title || ''}</h3><p>${item.description || ''}</p></li>`).join('');
                return `<section><h2>${blockTitle}</h2><ul>${listItems}</ul></section>`;
              }
              case 'products': {
                const listItems = (b.items || []).map(item => `<li><h3>${item.name || item.title || ''}</h3><p>${item.description || ''}</p><span>${item.price || ''}</span></li>`).join('');
                return `<section><h2>${blockTitle}</h2><ul>${listItems}</ul></section>`;
              }
              case 'pricing': {
                const listItems = (b.items || []).map(item => `<li><h3>${item.name || item.title || ''}</h3><p>${item.price || ''}</p></li>`).join('');
                return `<section><h2>${blockTitle}</h2><ul>${listItems}</ul></section>`;
              }
              case 'faq': {
                const listItems = (b.items || []).map(item => `<div><h3>${item.question || item.title || ''}</h3><p>${item.answer || item.description || ''}</p></div>`).join('');
                return `<section><h2>${blockTitle}</h2>${listItems}</section>`;
              }
              case 'testimonials': {
                const listItems = (b.items || []).map(item => `<blockquote><p>${item.quote || item.feedback || item.description || ''}</p><cite>- ${item.name || ''} (${item.role || ''})</cite></blockquote>`).join('');
                return `<section><h2>${blockTitle}</h2>${listItems}</section>`;
              }
              case 'contact_info':
                return `<section><h2>${blockTitle}</h2><p>Email: ${b.email || ''}</p><p>Phone: ${b.phone || ''}</p><p>Location: ${b.location || ''}</p></section>`;
              case 'lead_form':
              case 'lead_magnet':
                return `<section><h2>${blockTitle}</h2><p>${blockSub}</p></section>`;
              case 'basic_section':
                return `<section><h2>${blockTitle}</h2><p>${b.content || b.description || ''}</p></section>`;
              case 'working_hours':
                return `<section><h2>${blockTitle || 'Working Hours'}</h2></section>`;
              case 'location_map':
                return `<section><h2>${blockTitle || 'Location'}</h2><p>${b.address || ''}</p></section>`;
              case 'qr_code':
              case 'social_qr':
                return `<section><h2>${blockTitle}</h2><p>${blockSub}</p></section>`;
              default:
                return blockTitle ? `<section><h2>${blockTitle}</h2><p>${blockSub}</p></section>` : '';
            }
          }).join('\n');

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
                <script type="application/ld+json">
                {
                  "@context": "https://schema.org",
                  "@type": "WebPage",
                  "name": "${title}",
                  "description": "${description}",
                  "image": "${ogImage}"
                }
                </script>
                ${fbPixelId ? `
                <!-- Facebook Pixel Code -->
                <script>
                  !function(f,b,e,v,n,t,s)
                  {if(f.fbq)return;n=f.fbq=function(){n.callMethod?
                  n.callMethod.apply(n,arguments):n.queue.push(arguments)};
                  if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';
                  n.queue=[];t=b.createElement(e);t.async=!0;
                  t.src=v;s=b.getElementsByTagName(e)[0];
                  s.parentNode.insertBefore(t,s)}(window, document,'script',
                  'https://connect.facebook.net/en_US/fbevents.js');
                  fbq('init', '${fbPixelId}');
                  fbq('track', 'PageView');
                </script>
                <noscript>
                  <img height="1" width="1" style="display:none" src="https://www.facebook.com/tr?id=${fbPixelId}&ev=PageView&noscript=1"/>
                </noscript>
                <!-- End Facebook Pixel Code -->
                ` : ''}
                ${tiktokPixelId ? `
                <!-- TikTok Pixel Code -->
                <script>
                  !function (w, d, t) {
                    w.TiktokAnalyticsObject=t;var ttq=w[t]=w[t]||[];ttq.methods=["page","track","identify","instances","debug","on","off","once","ready","alias","group","enableCookie","disableCookie","holdConsent","revokeConsent","grantConsent"],ttq.setAndDefer=function(t,e){t[e]=function(){t.push([e].concat(Array.prototype.slice.call(arguments,0)))}};for(var e=0;e<ttq.methods.length;e++)ttq.setAndDefer(ttq,ttq.methods[e]);ttq.instance=function(t){for(var e=ttq._i[t]||[],n=0;n<ttq.methods.length;n++)ttq.setAndDefer(e,ttq.methods[n]);return e};ttq.load=function(e,n){var r="https://analytics.tiktok.com/i18n/pixel/events.js",o=n&&n.partner;ttq._i=ttq._i||{},ttq._i[e]=[],ttq._i[e]._u=r,ttq._t=ttq._t||{},ttq._t[e]=+new Date,ttq._o=ttq._o||{},ttq._o[e]=n||{};var a=d.createElement("script");a.type="text/javascript",a.async=!0,a.src=r;var c=d.getElementsByTagName("script")[0];c.parentNode.insertBefore(a,c)};
                    ttq.load('${tiktokPixelId}');
                    ttq.page();
                  }(window, document, 'ttq');
                </script>
                <!-- End TikTok Pixel Code -->
                ` : ''}
                ${snapPixelId ? `
                <!-- Snapchat Pixel Code -->
                <script>
                  (function(e,t,n){if(e.snaptr)return;var a=e.snaptr=function(){a.handleRequest?a.handleRequest.apply(a,arguments):a.queue.push(arguments)};a.queue=[];var o=t.createElement(n);o.async=!0;o.src="https://sc-static.net/scevent.min.js";var r=t.getElementsByTagName(n)[0];r.parentNode.insertBefore(o,r)})(window,document,"script");
                  snaptr('init', '${snapPixelId}');
                  snaptr('track', 'PAGE_VIEW');
                </script>
                <!-- End Snapchat Pixel Code -->
                ` : ''}
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
}


// Next.js (Vercel) automatically ignores /_next/ requests in middleware by default.
// We MUST explicitly tell it to run on EVERYTHING so we can proxy /_next/ to the blog.
export const config = {
  matcher: [
    '/:path*'
  ],
};
