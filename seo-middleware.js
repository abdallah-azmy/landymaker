export const config = {
  runtime: 'edge',
};

export default async function handler(request) {
  const url = new URL(request.url);
  const userAgent = request.headers.get('user-agent') || '';
  const isBot = /bot|googlebot|crawler|spider|robot|crawling|ai|gptbot/i.test(userAgent);

  // Extract slug from path (e.g. landymaker.com/my-barber)
  const pathSegments = url.pathname.split('/').filter(Boolean);
  if (pathSegments.length === 0 || ['login', 'register', 'dashboard', 'builder'].includes(pathSegments[0])) {
    return; // Pass through to Flutter SPA
  }

  const slug = pathSegments[0];

  if (isBot) {
    // 1. Fetch page data from Supabase REST API
    const SUPABASE_URL = process.env.SUPABASE_URL;
    const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

    try {
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

        const title = design.meta_title || `${slug} | LandyMaker`;
        const description = design.meta_description || "Created with LandyMaker.com";

        // 2. Return lightweight HTML for bots
        return new Response(
          `<!DOCTYPE html>
          <html>
            <head>
              <title>${title}</title>
              <meta name="description" content="${description}">
              <meta property="og:title" content="${title}">
              <meta property="og:description" content="${description}">
              <style>body { font-family: sans-serif; padding: 40px; text-align: center; }</style>
            </head>
            <body>
              <h1>${title}</h1>
              <p>${description}</p>
              <hr>
              <p>This is a dynamic landing page created on LandyMaker. Visit the link in a browser to see the full interactive version.</p>
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

  // Real humans get the Flutter app
  return;
}
