#!/bin/sh

# Script d'entrée Docker pour Nuxt 3
set -e

# Vérification du nombre de tentatives pour éviter les boucles infinies
RESTART_COUNT_FILE="/tmp/restart_count"
if [ -f "$RESTART_COUNT_FILE" ]; then
    RESTART_COUNT=$(cat "$RESTART_COUNT_FILE")
    RESTART_COUNT=$((RESTART_COUNT + 1))
else
    RESTART_COUNT=1
fi

echo $RESTART_COUNT > "$RESTART_COUNT_FILE"

if [ $RESTART_COUNT -gt 10 ]; then
    echo "❌ Trop de tentatives de redémarrage ($RESTART_COUNT). Arrêt pour éviter une boucle infinie."
    echo "🔧 Vérifiez la configuration Docker et les variables d'environnement."
    sleep 3600  # Attendre 1 heure avant de tenter à nouveau
    exit 1
fi

echo "🚀 Démarrage du container Nuxt 3... (Tentative #$RESTART_COUNT)"
echo "📍 Répertoire de travail: $(pwd)"
echo "📁 Contenu du répertoire:"
ls -la

# Copie des fichiers de configuration pré-définis si ils n'existent pas
if [ ! -f "/app/package.json" ]; then
    echo "📋 Copie des fichiers de configuration depuis /docker-files/..."
    cp -r /docker-files/* /app/ 2>/dev/null || true
    echo "✅ Fichiers copiés"
fi

# Génération du fichier .env pour Nuxt
echo "🔧 Génération du fichier .env pour Nuxt..."
cat > /app/.env << EOF
# =============================================================================
# Configuration Nuxt Website - Généré automatiquement
# =============================================================================
# Date de génération: $(date)

# Configuration de base
NODE_ENV=${NODE_ENV:-development}
NITRO_HOST=${NITRO_HOST:-0.0.0.0}
NITRO_PORT=${NITRO_PORT:-3000}

# Configuration de session
SESSION_SECRET=${SESSION_SECRET:-nuxt-session-secret-key-change-in-production}

# Configuration des domaines
DOMAIN_WEBSITE=${DOMAIN_WEBSITE:-localhost:3333}
DOMAIN_STRAPI=${DOMAIN_STRAPI:-localhost:1337}
DOMAIN_NOCODB=${DOMAIN_NOCODB:-localhost:8080}
DOMAIN_N8N=${DOMAIN_N8N:-localhost:5678}
DOMAIN_METABASE=${DOMAIN_METABASE:-localhost:3000}
DOMAIN_SERPBEAR=${DOMAIN_SERPBEAR:-localhost:3001}
DOMAIN_PGADMIN=${DOMAIN_PGADMIN:-localhost:5050}

# APIs Strapi
STRAPI_URL=http://strapi:1337
STRAPI_API_TOKEN=${STRAPI_API_TOKEN:-}

# Base de données PostgreSQL
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=${POSTGRES_DB:-automation_hub}
POSTGRES_USER=${POSTGRES_USER:-admin_user}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-}

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# Google APIs
GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID:-}
GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-}
GOOGLE_TAG=${GOOGLE_ANALYTICS_PROPERTY_ID:-}
GOOGLE_ANALYTICS_PROPERTY_ID=${GOOGLE_ANALYTICS_PROPERTY_ID:-}
GOOGLE_ADS_CUSTOMER_ID=${GOOGLE_ADS_CUSTOMER_ID:-}

# Brevo (ex-Sendinblue)
BREVO_API_KEY=${BREVO_API_KEY:-}
BREVO_WEBHOOK_SECRET=${BREVO_WEBHOOK_SECRET:-}

# Réseaux Sociaux
FACEBOOK_APP_ID=${FACEBOOK_APP_ID:-}
FACEBOOK_APP_SECRET=${FACEBOOK_APP_SECRET:-}
INSTAGRAM_ACCESS_TOKEN=${INSTAGRAM_ACCESS_TOKEN:-}
LINKEDIN_CLIENT_ID=${LINKEDIN_CLIENT_ID:-}
LINKEDIN_CLIENT_SECRET=${LINKEDIN_CLIENT_SECRET:-}

# IA et APIs
OPENAI_API_KEY=${OPENAI_API_KEY:-}
GOOGLE_VERTEX_AI_PROJECT_ID=${GOOGLE_VERTEX_AI_PROJECT_ID:-}
GOOGLE_VERTEX_AI_LOCATION=${GOOGLE_VERTEX_AI_LOCATION:-europe-west1}

# SerpBear
SERPBEAR_API_KEY=${SERPBEAR_API_KEY:-}

# Configuration Timezone
TIMEZONE=${TIMEZONE:-Europe/Paris}
EOF

echo "✅ Fichier .env généré avec succès"

# Vérification de la présence des fichiers essentiels
echo "🔍 Vérification des fichiers essentiels..."
if [ ! -f "/app/package.json" ]; then
    echo "❌ Erreur: package.json manquant!"
    exit 1
fi

if [ ! -f "/app/nuxt.config.ts" ]; then
    echo "❌ Erreur: nuxt.config.ts manquant!"
    exit 1
fi

echo "✅ Fichiers essentiels présents"

# Installation des dépendances
echo "📦 Vérification des dépendances..."
if [ ! -d "node_modules" ] || [ ! -f "node_modules/.yarn-integrity" ]; then
    echo "⬇️ Installation des dépendances avec Yarn..."
    # Tentative avec --frozen-lockfile d'abord
    if ! yarn install --frozen-lockfile --non-interactive 2>/dev/null; then
        echo "⚠️ Lockfile obsolète, mise à jour en cours..."
        yarn install --non-interactive
    fi
    echo "✅ Dépendances installées"
else
    echo "✅ Dépendances déjà installées"
fi

# Vérification que Nuxt est disponible
echo "🔍 Vérification de l'installation de Nuxt..."
if ! yarn nuxt --version > /dev/null 2>&1; then
    echo "❌ Erreur: Nuxt n'est pas correctement installé"
    echo "🔄 Tentative de réinstallation..."
    rm -rf node_modules yarn.lock
    yarn install --non-interactive
    if ! yarn nuxt --version > /dev/null 2>&1; then
        echo "❌ Échec de l'installation de Nuxt après réinstallation"
        echo "📋 Contenu du package.json:"
        cat package.json
        exit 1
    fi
fi

# Génération des types Nuxt
echo "🔄 Préparation de Nuxt..."
if ! yarn nuxt prepare; then
    echo "❌ Erreur lors de la préparation de Nuxt"
    echo "🔄 Tentative de nettoyage et réinstallation..."
    rm -rf node_modules yarn.lock .nuxt
    yarn install --non-interactive
    if ! yarn nuxt prepare; then
        echo "❌ Échec définitif de la préparation de Nuxt"
        exit 1
    fi
fi

# Démarrage en fonction de l'environnement
if [ "$NODE_ENV" = "production" ]; then
    echo "🏭 Démarrage en mode production..."
    yarn build && yarn preview
else
    echo "🛠️ Démarrage en mode développement..."
    yarn dev
fi