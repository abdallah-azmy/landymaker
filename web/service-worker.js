const CACHE_NAME = 'landymaker-v1';
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/favicon.png',
  '/logo_social.webp',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
  '/flutter.js',
  '/flutter_bootstrap.js',
  '/main.dart.js',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS);
    }).then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key)),
      );
    }).then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Cache-first for static assets
  if (STATIC_ASSETS.includes(url.pathname) ||
      url.pathname.startsWith('/assets/') ||
      url.pathname.startsWith('/icons/')) {
    event.respondWith(
      caches.match(request).then((cached) => cached || fetch(request)),
    );
    return;
  }

  // Network-first for API calls and dynamic content
  if (url.pathname.startsWith('/api/') ||
      url.hostname.includes('supabase')) {
    event.respondWith(
      fetch(request).catch(() => caches.match(request)),
    );
    return;
  }

  // Network-first with cache fallback for everything else
  event.respondWith(
    fetch(request).then((response) => {
      if (response.ok) {
        const clone = response.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
      }
      return response;
    }).catch(() => caches.match(request).then((cached) => {
      if (cached) return cached;
      return caches.match('/');
    })),
  );
});
