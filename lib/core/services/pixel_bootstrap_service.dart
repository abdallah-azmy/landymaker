import 'dart:html' as html;

class PixelBootstrapService {
  static void initialize(Map<String, dynamic> designMap) {
    // Check local storage for consent status
    final consent = html.window.localStorage['cookie_consent_status'];
    if (consent != 'accepted') {
      // Consent not accepted yet, or rejected
      return;
    }

    final fbPixelId = designMap['fb_pixel_id']?.toString() ?? '';
    final tiktokPixelId = designMap['tiktok_pixel_id']?.toString() ?? '';
    final snapPixelId = designMap['snap_pixel_id']?.toString() ?? '';

    _cleanUp();

    if (fbPixelId.isNotEmpty) {
      _injectFbPixel(fbPixelId);
    }
    if (tiktokPixelId.isNotEmpty) {
      _injectTiktokPixel(tiktokPixelId);
    }
    if (snapPixelId.isNotEmpty) {
      _injectSnapPixel(snapPixelId);
    }
  }

  static void _cleanUp() {
    // Remove existing script tags matching our class name to prevent duplicates
    html.document.querySelectorAll('.injected-pixel-script').forEach((el) => el.remove());
  }

  static void _injectFbPixel(String pixelId) {
    final script = html.ScriptElement()
      ..className = 'injected-pixel-script'
      ..id = 'fb-pixel-script'
      ..text = '''
        !function(f,b,e,v,n,t,s)
        {if(f.fbq)return;n=f.fbq=function(){n.callMethod?
        n.callMethod.apply(n,arguments):n.queue.push(arguments)};
        if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';
        n.queue=[];t=b.createElement(e);t.async=!0;
        t.src=v;s=b.getElementsByTagName(e)[0];
        s.parentNode.insertBefore(t,s)}(window, document,'script',
        'https://connect.facebook.net/en_US/fbevents.js');
        fbq('init', '$pixelId');
        fbq('track', 'PageView');
      ''';
    html.document.head!.append(script);
  }

  static void _injectTiktokPixel(String pixelId) {
    final script = html.ScriptElement()
      ..className = 'injected-pixel-script'
      ..id = 'tiktok-pixel-script'
      ..text = '''
        !function (w, d, t) {
          w.TiktokAnalyticsObject=t;var ttq=w[t]=w[t]||[];ttq.methods=["page","track","identify","instances","debug","on","off","once","ready","alias","group","enableCookie","disableCookie","holdConsent","revokeConsent","grantConsent"],ttq.setAndDefer=function(t,e){t[e]=function(){t.push([e].concat(Array.prototype.slice.call(arguments,0)))}};for(var e=0;e<ttq.methods.length;e++)ttq.setAndDefer(ttq,ttq.methods[e]);ttq.instance=function(t){for(var e=ttq._i[t]||[],n=0;n<ttq.methods.length;n++)ttq.setAndDefer(e,ttq.methods[n]);return e};ttq.load=function(e,n){var r="https://analytics.tiktok.com/i18n/pixel/events.js",o=n&&n.partner;ttq._i=ttq._i||{},ttq._i[e]=[],ttq._i[e]._u=r,ttq._t=ttq._t||{},ttq._t[e]=+new Date,ttq._o=ttq._o||{},ttq._o[e]=n||{};var a=d.createElement("script");a.type="text/javascript",a.async=!0,a.src=r;var c=d.getElementsByTagName("script")[0];c.parentNode.insertBefore(a,c)};
          ttq.load('$pixelId');
          ttq.page();
        }(window, document, 'ttq');
      ''';
    html.document.head!.append(script);
  }

  static void _injectSnapPixel(String pixelId) {
    final script = html.ScriptElement()
      ..className = 'injected-pixel-script'
      ..id = 'snap-pixel-script'
      ..text = '''
        (function(e,t,n){if(e.snaptr)return;var a=e.snaptr=function(){a.handleRequest?a.handleRequest.apply(a,arguments):a.queue.push(arguments)};a.queue=[];var o=t.createElement(n);o.async=!0;o.src="https://sc-static.net/scevent.min.js";var r=t.getElementsByTagName(n)[0];r.parentNode.insertBefore(o,r)})(window,document,"script");
        snaptr('init', '$pixelId');
        snaptr('track', 'PAGE_VIEW');
      ''';
    html.document.head!.append(script);
  }
}
