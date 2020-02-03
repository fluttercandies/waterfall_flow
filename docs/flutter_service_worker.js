'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "/assets\AssetManifest.json": "ca6345207bb0806d4b47f879655d9728",
"/assets\assets\avatar.jpg": "c1916ddb1a8e3f82054850e79c24ac84",
"/assets\FontManifest.json": "f7161631e25fbd47f3180eae84053a51",
"/assets\fonts\MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"/assets\LICENSE": "7578b7b08b9fd56722d732df63c8c0b1",
"/assets\packages\cupertino_icons\assets\CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"/assets\packages\flutter_candies_demo_library\assets\40.png": "d31f4ff6176bedac2101b1cbb9083f36",
"/assets\packages\flutter_candies_demo_library\assets\avatar.jpg": "c1916ddb1a8e3f82054850e79c24ac84",
"/assets\packages\flutter_candies_demo_library\assets\flutterCandies_grey.png": "5fac6a25f94b0f5e26acaa5bf75433b2",
"/assets\packages\flutter_candies_demo_library\assets\love.png": "5370bcbe694c796309acc76760288878",
"/assets\packages\flutter_candies_demo_library\assets\sun_glasses.png": "c2e38170a5e3a0883b0c436f6e799e36",
"/assets\packages\loading_more_list\assets\empty.jpeg": "52a69bab9f87bcf0052d8e55ea314977",
"/icons\Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"/icons\Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"/index.html": "90cdef674b77320f4c85258dfba10a7e",
"/main.dart.js": "afaacd098b616b9978219fbb83323832",
"/manifest.json": "8e35f4c50b4f0b36c6903f5acde238a1"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request, {
          credentials: 'include'
        });
      })
  );
});
