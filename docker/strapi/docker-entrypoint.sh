#!/bin/sh

# Script d'entrée Docker pour Strapi CMS
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

echo "🚀 Démarrage du container Strapi CMS... (Tentative #$RESTART_COUNT)"
echo "📍 Répertoire de travail: $(pwd)"
echo "📁 Contenu du répertoire:"
ls -la

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente de la disponibilité de PostgreSQL..."
while ! nc -z ${DATABASE_HOST:-postgres} ${DATABASE_PORT:-5432}; do
    echo "⏳ PostgreSQL n'est pas encore prêt, attente..."
    sleep 2
done
echo "✅ PostgreSQL est disponible"

# Copie des fichiers de configuration pré-définis si ils n'existent pas
if [ ! -f "/opt/app/package.json" ]; then
    echo "📋 Copie des fichiers de configuration depuis /docker-files/..."
    cp -r /docker-files/* /opt/app/ 2>/dev/null || true
    echo "✅ Fichiers copiés"
fi

# Génération du fichier .env pour Strapi
echo "🔧 Génération du fichier .env pour Strapi..."
cat > /opt/app/.env << EOF
# =============================================================================
# Configuration Strapi CMS - Généré automatiquement
# =============================================================================
# Date de génération: $(date)

# Configuration de base
NODE_ENV=${NODE_ENV:-development}
HOST=${HOST:-0.0.0.0}
PORT=${PORT:-1337}

# Configuration de la base de données PostgreSQL
DATABASE_CLIENT=postgres
DATABASE_HOST=${DATABASE_HOST:-postgres}
DATABASE_PORT=${DATABASE_PORT:-5432}
DATABASE_NAME=${DATABASE_NAME:-strapi_cms}
DATABASE_USERNAME=${DATABASE_USERNAME:-admin_user}
DATABASE_PASSWORD=${DATABASE_PASSWORD:-}
DATABASE_SSL=false
DATABASE_SCHEMA=public

# Clés de sécurité Strapi
APP_KEYS=${STRAPI_APP_KEYS:-}
JWT_SECRET=${STRAPI_JWT_SECRET:-}
ADMIN_JWT_SECRET=${STRAPI_ADMIN_JWT_SECRET:-}
API_TOKEN_SALT=${STRAPI_API_TOKEN_SALT:-}
TRANSFER_TOKEN_SALT=${STRAPI_TRANSFER_TOKEN_SALT:-}

# Configuration des uploads et média
UPLOAD_PROVIDER=local
MAX_FILE_SIZE=50000000

# Configuration de développement
STRAPI_HIDE_STARTUP_MESSAGE=false
STRAPI_LOG_LEVEL=info

# Flags de fonctionnalités
FLAG_NPS=${FLAG_NPS:-false}
FLAG_PROMOTE_EE=${FLAG_PROMOTE_EE:-false}

# Configuration Email (Brevo/Sendinblue)
EMAIL_PROVIDER=sendmail
BREVO_API_KEY=${BREVO_API_KEY:-}

# Configuration des APIs externes
GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID:-}
GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-}
OPENAI_API_KEY=${OPENAI_API_KEY:-}

# Configuration Timezone
TZ=${TIMEZONE:-Europe/Paris}
EOF

echo "✅ Fichier .env généré avec succès"

# Vérification de la présence des fichiers essentiels
echo "🔍 Vérification des fichiers essentiels..."
if [ ! -f "/opt/app/package.json" ]; then
    echo "❌ Erreur: package.json manquant!"
    exit 1
fi

echo "✅ Fichiers essentiels présents"

# Installation des dépendances
echo "📦 Vérification des dépendances..."
if [ ! -d "node_modules" ] || [ ! -f "node_modules/.yarn-integrity" ]; then
    echo "⬇️ Installation des dépendances avec Yarn..."
    # Nettoyage préventif
    rm -f yarn.lock package-lock.json
    
    # Installation avec retry logic
    for i in $(seq 1 3); do
        echo "Tentative d'installation #$i..."
        if yarn install --non-interactive --frozen-lockfile 2>/dev/null; then
            echo "✅ Installation réussie"
            break
        elif [ $i -eq 3 ]; then
            echo "🔄 Installation sans lockfile (dernière tentative)..."
            yarn install --non-interactive
            break
        else
            echo "⚠️ Échec de la tentative #$i, nouvelle tentative..."
            sleep 2
        fi
    done
else
    echo "✅ Dépendances déjà installées"
fi

# Vérification que Strapi est disponible
echo "🔍 Vérification de l'installation de Strapi..."
if ! yarn strapi version > /dev/null 2>&1; then
    echo "❌ Erreur: Strapi n'est pas correctement installé"
    echo "🔄 Tentative de réinstallation..."
    rm -rf node_modules yarn.lock
    yarn install --non-interactive
    
    if ! yarn strapi version > /dev/null 2>&1; then
        echo "❌ Impossible d'installer Strapi correctement"
        exit 1
    fi
fi

echo "✅ Strapi $(yarn strapi version) installé"

# Test de connectivité à la base de données
echo "🔍 Test de connectivité à la base de données..."
if command -v psql > /dev/null 2>&1; then
    if PGPASSWORD="${DATABASE_PASSWORD}" psql -h "${DATABASE_HOST}" -p "${DATABASE_PORT}" -U "${DATABASE_USERNAME}" -d "${DATABASE_NAME}" -c "SELECT 1;" > /dev/null 2>&1; then
        echo "✅ Connexion à la base de données réussie"
    else
        echo "⚠️ Impossible de se connecter à la base de données (peut être normal au premier démarrage)"
    fi
else
    echo "⚠️ psql non disponible, saut du test de connectivité"
fi

# Construction de Strapi si nécessaire
if [ "$NODE_ENV" = "production" ]; then
    echo "🏗️ Construction de Strapi pour la production..."
    yarn build
    echo "✅ Construction terminée"
fi

# Génération des types TypeScript pour Strapi
echo "🔄 Génération des types TypeScript..."
if ! yarn strapi ts:generate-types > /dev/null 2>&1; then
    echo "⚠️ Impossible de générer les types TypeScript (normal au premier démarrage)"
fi

# Démarrage de Strapi
echo "🚀 Démarrage de Strapi CMS..."
if [ "$NODE_ENV" = "production" ]; then
    yarn start
else
    yarn develop
fi
