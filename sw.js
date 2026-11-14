/* Field Notes offline support: keeps a copy of the app on the phone so it opens without signal.
   Pages and settings: network first, the saved copy when offline. Fonts, icons and the database library: saved copy first. */
var CACHE = 'field-notes-v1.3.3';
var SHELL = ['./', 'index.html', 'config.js', 'manifest.webmanifest', 'version.json',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.117.2/dist/umd/supabase.js'];

self.addEventListener('install', function (e) {
  e.waitUntil(caches.open(CACHE).then(function (c) {
    return Promise.all(SHELL.map(function (u) { return c.add(new Request(u, { cache: 'reload' })).catch(function () {}); }));
  }).then(function () { return self.skipWaiting(); }));
});
self.addEventListener('activate', function (e) {
  e.waitUntil(caches.keys().then(function (keys) {
    return Promise.all(keys.filter(function (k) { return k.indexOf('field-notes-') === 0 && k !== CACHE; }).map(function (k) { return caches.delete(k); }));
  }).then(function () { return self.clients.claim(); }));
});
self.addEventListener('fetch', function (e) {
  var req = e.request, url = new URL(req.url);
  if (req.method !== 'GET') return;
  if (/supabase\.co$/.test(url.hostname)) return; // live data is never cached here; the app keeps its own copy
  var sameOrigin = url.origin === self.location.origin;
  var staticAsset = !sameOrigin || /\/icons\//.test(url.pathname);
  if (staticAsset) {
    e.respondWith(caches.match(req).then(function (hit) {
      return hit || fetch(req).then(function (res) {
        if (res && (res.ok || res.type === 'opaque')) { var copy = res.clone(); caches.open(CACHE).then(function (c) { c.put(req, copy); }); }
        return res;
      });
    }));
    return;
  }
  e.respondWith(fetch(req).then(function (res) {
    if (res && res.ok) { var copy = res.clone(); caches.open(CACHE).then(function (c) { c.put(req.mode === 'navigate' ? './' : req, copy); }); }
    return res;
  }).catch(function () {
    return caches.match(req, { ignoreSearch: true }).then(function (hit) { return hit || (req.mode === 'navigate' ? caches.match('./') : undefined); });
  }));
});
