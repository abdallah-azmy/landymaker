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
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
