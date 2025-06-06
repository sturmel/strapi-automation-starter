import tailwindcss from "@tailwindcss/vite";

export default defineNuxtConfig({
  compatibilityDate: '2025-05-15',
  devtools: { enabled: true },
  modules: [
    '@nuxt/eslint',
    '@nuxt/fonts',
    '@nuxt/icon',
    '@nuxt/image',
    '@nuxt/scripts',
    '@nuxt/test-utils',
    'nuxt-gtag',
  ],
  gtag: {
    id: process.env.GOOGLE_TAG || process.env.GOOGLE_ANALYTICS_PROPERTY_ID
  },
  css: ['~/assets/css/main.css'],
  vite: {
    plugins: [
      tailwindcss(),
    ],
    build: {
      sourcemap: true, 
    },
  },
  nitro: {
    compressPublicAssets: true,
    prerender: {
      crawlLinks: true   
    }
  },
  runtimeConfig: {
    // Variables privées (côté serveur seulement)
    strapiUrl: process.env.STRAPI_URL,
    strapiApiToken: process.env.STRAPI_API_TOKEN,
    sessionSecret: process.env.SESSION_SECRET,
    
    public: {
      // Variables publiques (accessibles côté client)
      googleTag: process.env.GOOGLE_TAG,
      googleAnalyticsPropertyId: process.env.GOOGLE_ANALYTICS_PROPERTY_ID,
      
      // Configuration générale
      nodeEnv: process.env.NODE_ENV,
    }
  }
})