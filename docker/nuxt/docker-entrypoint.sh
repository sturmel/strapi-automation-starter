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

# APIs Strapi (backend CMS)
STRAPI_URL=http://strapi:1337
STRAPI_API_TOKEN=${STRAPI_API_TOKEN:-}

# Google Analytics (optionnel)
GOOGLE_TAG=${GOOGLE_ANALYTICS_PROPERTY_ID:-}
GOOGLE_ANALYTICS_PROPERTY_ID=${GOOGLE_ANALYTICS_PROPERTY_ID:-}
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