enum RouteMode { dashboard, publicViewer }

class TenantRoutingService {
  /// Determines if the application should load the builder dashboard or the public viewer
  static RouteMode getRouteMode() {
    final uri = Uri.base;
    final host = uri.host.toLowerCase();

    // 1. Localhost development/testing fallback
    if (host == 'localhost' || host == '127.0.0.1') {
      if (uri.queryParameters.containsKey('tenant') || uri.queryParameters.containsKey('subdomain')) {
        return RouteMode.publicViewer;
      }
      return RouteMode.dashboard;
    }

    // 2. Core platform subdomains or root domain
    if (host.startsWith('dashboard.') || 
        host.startsWith('app.') || 
        host == 'mylandy.com' ||
        host == 'mylandy-builder.vercel.app') {
      return RouteMode.dashboard;
    }

    // 3. Any other host is classified as a tenant public page (e.g. tenant.mylandy.com or a custom domain)
    return RouteMode.publicViewer;
  }

  /// Extracts the subdomain string or custom domain from the current host
  static String? getTenantIdentifier() {
    final uri = Uri.base;
    final host = uri.host.toLowerCase();

    // 1. Localhost development query fallback
    if (host == 'localhost' || host == '127.0.0.1') {
      return uri.queryParameters['tenant'] ?? uri.queryParameters['subdomain'];
    }

    // 2. Parse tenant subdomain (e.g. "tenant.mylandy.com" or "tenant.mylandy-builder.vercel.app")
    if (host.endsWith('.mylandy.com')) {
      final parts = host.split('.');
      return parts[0]; // Returns "tenant"
    } else if (host.endsWith('.mylandy-builder.vercel.app')) {
      final parts = host.split('.');
      return parts[0]; // Returns "tenant"
    }

    // 3. Otherwise, return full hostname to match custom_domain column in Supabase
    if (host != 'mylandy.com' && !host.startsWith('dashboard.') && !host.startsWith('app.')) {
      return host; 
    }

    return null;
  }

  /// Check if the parsed tenant is a custom domain instead of a subdomain
  static bool isCustomDomain(String identifier) {
    // If it does not contain a dot, or it's a localhost, it is a subdomain
    if (!identifier.contains('.')) {
      return false;
    }
    return true;
  }
}
