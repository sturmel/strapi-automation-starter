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
    
    // Base de données
    postgresHost: process.env.POSTGRES_HOST,
    postgresPort: process.env.POSTGRES_PORT,
    postgresDb: process.env.POSTGRES_DB,
    postgresUser: process.env.POSTGRES_USER,
    postgresPassword: process.env.POSTGRES_PASSWORD,
    
    // Redis
    redisHost: process.env.REDIS_HOST,
    redisPort: process.env.REDIS_PORT,
    
    // APIs privées
    openaiApiKey: process.env.OPENAI_API_KEY,
    brevoApiKey: process.env.BREVO_API_KEY,
    googleClientSecret: process.env.GOOGLE_CLIENT_SECRET,
    facebookAppSecret: process.env.FACEBOOK_APP_SECRET,
    linkedinClientSecret: process.env.LINKEDIN_CLIENT_SECRET,
    
    public: {
      // Variables publiques (accessibles côté client)
      domainWebsite: process.env.DOMAIN_WEBSITE,
      domainStrapi: process.env.DOMAIN_STRAPI,
      domainNocodb: process.env.DOMAIN_NOCODB,
      domainN8n: process.env.DOMAIN_N8N,
      domainMetabase: process.env.DOMAIN_METABASE,
      domainSerpbear: process.env.DOMAIN_SERPBEAR,
      domainPgadmin: process.env.DOMAIN_PGADMIN,
      
      // APIs publiques
      googleClientId: process.env.GOOGLE_CLIENT_ID,
      googleTag: process.env.GOOGLE_TAG,
      googleAnalyticsPropertyId: process.env.GOOGLE_ANALYTICS_PROPERTY_ID,
      facebookAppId: process.env.FACEBOOK_APP_ID,
      linkedinClientId: process.env.LINKEDIN_CLIENT_ID,
      
      // Configuration générale
      nodeEnv: process.env.NODE_ENV,
      timezone: process.env.TIMEZONE,
    }
  }
})