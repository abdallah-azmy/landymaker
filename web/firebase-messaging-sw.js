importScripts('https://www.gstatic.com/firebasejs/9.22.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.1/firebase-messaging-compat.js');

const firebaseConfig = {
  apiKey: "AIzaSyA1RlGi-rc9h1LFmQuHibkc-43T3YUSdSc",
  authDomain: "landymaker-aab2e.firebaseapp.com",
  projectId: "landymaker-aab2e",
  storageBucket: "landymaker-aab2e.firebasestorage.app",
  messagingSenderId: "68293487460",
  appId: "1:68293487460:web:11c0fdc924fe1748136871",
  measurementId: "G-SP9P5B08X8"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  
  let targetUrl = '/dashboard/notifications';
  if (payload.data && (payload.data.click_action || payload.data.redirect_to)) {
    targetUrl = payload.data.click_action || payload.data.redirect_to;
  } else if (payload.data && payload.data.type === 'lead') {
    targetUrl = '/dashboard/leads';
  }

  const origin = self.location.origin;
  const fullTargetUrl = targetUrl.startsWith('http') ? targetUrl : (origin + targetUrl);

  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png',
    data: {
      click_action: fullTargetUrl
    }
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

self.addEventListener('notificationclick', function(event) {
  event.notification.close();

  let targetUrl = self.location.origin + '/dashboard/notifications';
  if (event.notification.data && event.notification.data.click_action) {
    targetUrl = event.notification.data.click_action;
  }

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(clientList) {
      // If a window is already open with the same origin, focus and navigate it
      for (let i = 0; i < clientList.length; i++) {
        let client = clientList[i];
        if (client.url.includes(self.location.origin) && 'focus' in client) {
          if (client.url !== targetUrl) {
            client.navigate(targetUrl);
          }
          return client.focus();
        }
      }
      // If no window is open, open a new one
      if (clients.openWindow) {
        return clients.openWindow(targetUrl);
      }
    })
  );
});
