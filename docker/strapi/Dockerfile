# Dockerfile pour Strapi CMS
FROM node:20-alpine

# Mise à jour et installation des dépendances système
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    wget \
    netcat-openbsd \
    postgresql-client \
    vips-dev \
    && corepack enable

# Création du répertoire de travail
WORKDIR /opt/app

# Variables d'environnement pour Node
ARG NODE_ENV=development
ENV NODE_ENV=$NODE_ENV
ENV HOST=0.0.0.0
ENV PORT=1337

# Script de démarrage conditionnel
COPY docker-entrypoint.sh /usr/local/bin/
COPY files/ /docker-files/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Création du dossier pour les uploads
RUN mkdir -p /opt/app/public/uploads

# Exposition du port
EXPOSE 1337

ENTRYPOINT ["docker-entrypoint.sh"]
