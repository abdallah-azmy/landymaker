enum RouteMode { dashboard, publicViewer, homePage }

class TenantRoutingService {
  static const String publicViewerIdentifier = 'public_viewer';

  /// Stores a template ID if the user clicked "Use this template" before logging in
  static String? pendingTemplateId;

  /// Defines reserved paths that are used for dashboard/auth and cannot be used as landing page slugs.
  static const Set<String> reservedPaths = {
    '',
    'blog',
    '_next',
    'login',
    'register',
    'signup',
    'signin',
    'forgot-password',
    'reset-password',
    'dashboard',
    'admin',
    'settings',
    'profile',
    'pricing',
    'plans',
    'billing',
    'checkout',
    'success',
    'cancel',
    'api',
    'auth',
    'app',
    'editor',
    'builder',
    'pages',
    'page',
    'store',
    'products',
    'orders',
    'analytics',
    'support',
    'help',
    'about',
    'contact',
    'privacy',
    'terms',
    'sitemap',
    'robots.txt',
    'favicon.ico',
    'home',
    'public_viewer',
    'assets',
    'images',
    'icons',
    'web',
  };

  /// Determines if the application should load the builder dashboard,
  /// the public viewer, or the marketing home page.
  static RouteMode getRouteMode() {
    final identifier = getTenantIdentifier();
    if (identifier != null) {
      return RouteMode.publicViewer;
    }
    // No tenant identifier AND we are on a core domain → show home page
    final uri = Uri.base;
    final host = uri.host.toLowerCase();
    final isCoreDomain = host == 'localhost' ||
        host == '127.0.0.1' ||
        host == 'landymaker.com' ||
        host == 'landymaker.vercel.app' ||
        host.startsWith('dashboard.') ||
        host.startsWith('app.');
    if (isCoreDomain) {
      return RouteMode.homePage;
    }
    return RouteMode.dashboard;
  }

  /// Extracts the slug, subdomain, or custom domain to load the correct landing page configuration
  static String? getTenantIdentifier() {
    final uri = Uri.base;
    final host = uri.host.toLowerCase();

    // 1. Check for path-based slug on core domains or localhost
    final isCoreDomain = host == 'localhost' ||
        host == '127.0.0.1' ||
        host == 'landymaker.com' ||
        host == 'landymaker.vercel.app' ||
        host.startsWith('dashboard.') ||
        host.startsWith('app.');

    if (isCoreDomain) {
      if (uri.pathSegments.isNotEmpty) {
        final firstSegment = uri.pathSegments.first.trim();
        if (firstSegment.isNotEmpty && !reservedPaths.contains(firstSegment)) {
          return firstSegment;
        }
      }

      // Localhost development query parameter fallback (?tenant=restaurant-x)
      if (host == 'localhost' || host == '127.0.0.1') {
        final queryVal = uri.queryParameters['tenant'] ?? uri.queryParameters['subdomain'];
        if (queryVal != null && queryVal.trim().isNotEmpty) {
          return queryVal.trim();
        }
      }
      return null;
    }

    // 3. Otherwise, treat host as custom domain (e.g. "myrestaurant.com")
    return host;
  }

  /// Check if the parsed tenant is a custom domain instead of a subdomain/slug
  static bool isCustomDomain(String identifier) {
    // If it contains a dot and is not a local host/domain name, classify as custom domain
    if (identifier.contains('.')) {
      if (identifier.endsWith('.landymaker.com') ||
          identifier.endsWith('.landymaker.vercel.app') ||
          identifier == 'localhost' ||
          identifier == '127.0.0.1') {
        return false;
      }
      return true;
    }
    return false;
  }
}
