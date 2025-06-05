export default ({ env }) => ({
  // Configuration Redis pour les sessions
  redis: {
    config: {
      connections: {
        default: {
          connection: {
            host: env('REDIS_HOST', 'redis'),
            port: env.int('REDIS_PORT', 6379),
            db: env.int('REDIS_DB', 0),
          },
          settings: {
            debug: false,
          },
        },
      },
    },
  },
});
