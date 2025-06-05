# Dockerfile pour Nuxt 3
FROM node:20-alpine

# Mise à jour et installation des dépendances système
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    wget \
    && corepack enable

# Création du répertoire de travail
WORKDIR /app

# Variables d'environnement pour Node
ENV NODE_ENV=$NODE_ENV
ENV NITRO_HOST=0.0.0.0
ENV NITRO_PORT=3000

# Script de démarrage conditionnel
COPY docker-entrypoint.sh /usr/local/bin/
COPY files/ /docker-files/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Exposition du port
EXPOSE 3000

ENTRYPOINT ["docker-entrypoint.sh"]