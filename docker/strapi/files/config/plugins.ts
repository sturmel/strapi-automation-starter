export default ({ env }) => ({
  // Configuration du plugin Users & Permissions
  'users-permissions': {
    enabled: true,
    config: {
      jwt: {
        expiresIn: '7d',
      },
    },
  },

  // Configuration du plugin Upload
  upload: {
    enabled: true,
    config: {
      sizeLimit: env.int('MAX_FILE_SIZE', 50000000), // 50MB par défaut
      breakpoints: {
        xlarge: 1920,
        large: 1000,
        medium: 750,
        small: 500,
        xsmall: 64,
      },
    },
  },

  // Configuration du plugin Cloud (si disponible)
  cloud: {
    enabled: env.bool('STRAPI_CLOUD_ENABLED', false),
  },
});
