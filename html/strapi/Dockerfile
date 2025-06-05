FROM node:20-alpine

# Installation des dépendances système
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    postgresql-client \
    git

# Création du répertoire de travail
WORKDIR /opt/app

# Création de Strapi avec SQLite par défaut (plus simple)
RUN npx create-strapi-app@latest . --quickstart --no-run --skip-cloud

# Installation du driver PostgreSQL
RUN npm install pg

# Copie des fichiers de configuration après création
COPY config/ ./config/

# Script de démarrage conditionnel
RUN echo '#!/bin/sh' > /opt/app/start.sh && \
    echo 'if [ "$NODE_ENV" = "production" ]; then' >> /opt/app/start.sh && \
    echo '  echo "🚀 Starting Strapi in PRODUCTION mode"' >> /opt/app/start.sh && \
    echo '  npm run build' >> /opt/app/start.sh && \
    echo '  npm run start' >> /opt/app/start.sh && \
    echo 'else' >> /opt/app/start.sh && \
    echo '  echo "🔧 Starting Strapi in DEVELOPMENT mode"' >> /opt/app/start.sh && \
    echo '  npm run develop' >> /opt/app/start.sh && \
    echo 'fi' >> /opt/app/start.sh && \
    chmod +x /opt/app/start.sh

# Exposition du port
EXPOSE 1337

# Commande de démarrage conditionnel
CMD ["/opt/app/start.sh"]
