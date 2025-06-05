# 🚀 Marketing Automation Hub

Plateforme complète d'automatisation marketing avec Docker Compose, intégrant n8n, NocoDB, Metabase, Strapi, SerpBear et bien plus.

## 📋 Table des matières

- [Vue d'ensemble](#-vue-densemble)
- [Architecture](#-architecture)
- [Services inclus](#-services-inclus)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Workflows n8n](#-workflows-n8n)
- [Base de données](#-base-de-données)
- [APIs et intégrations](#-apis-et-intégrations)
- [Tableaux de bord Metabase](#-tableaux-de-bord-metabase)
- [Dépannage](#-dépannage)
- [Sécurité](#-sécurité)

## 🎯 Vue d'ensemble

Cette plateforme automatise entièrement votre stack marketing en connectant :

1. **Collecte automatique** : n8n collecte les données depuis Google Ads/Analytics, Brevo, réseaux sociaux, SerpBear
2. **Stockage structuré** : PostgreSQL avec schémas optimisés pour l'analyse
3. **Interface no-code** : NocoDB pour gérer les leads et données
4. **Analytics avancés** : Metabase pour visualiser les KPIs
5. **IA intégrée** : Génération automatique de contenu et recommandations
6. **CMS headless** : Strapi pour la gestion de contenu
7. **Site web** : Nuxt3 avec interface moderne

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   APIs External │    │      n8n        │    │   PostgreSQL    │
│   (Google, Brevo)│────│   Workflows     │────│   Marketing     │
│   Social Media  │    │   Automation    │    │   Database      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                        │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     NocoDB      │────│     Redis       │    │    Metabase     │
│   Data Mgmt     │    │     Cache       │    │   Analytics     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nuxt3 Site    │────│     Nginx       │    │    SerpBear     │
│   Frontend      │    │  Reverse Proxy  │    │   SEO Tracking  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🛠️ Services inclus

| Service | Port | Description | URL |
|---------|------|-------------|-----|
| **Nuxt3 Website** | 3333 | Site web frontend | http://localhost:3333 |
| **Strapi CMS** | 1337 | Headless CMS | http://localhost:1337 |
| **NocoDB** | 8080 | Interface base de données | http://localhost:8080 |
| **n8n** | 5678 | Automatisation workflows | http://localhost:5678 |
| **Metabase** | 3000 | Analytics & BI | http://localhost:3000 |
| **SerpBear** | 3001 | SEO rank tracking | http://localhost:3001 |
| **pgAdmin** | 5050 | Administration PostgreSQL | http://localhost:5050 |
| **PostgreSQL** | 5432 | Base de données principale | - |
| **Redis** | 6379 | Cache et sessions | - |
| **Nginx** | 80/443 | Reverse proxy | http://localhost |

## 🚀 Installation

### Prérequis

- Docker 20.0+
- Docker Compose 2.0+
- 4GB RAM minimum (8GB recommandé)
- 20GB espace disque

### Installation rapide

```bash
# Cloner le repository
git clone <your-repo-url>
cd strapi-automation-starter

# Rendre le script exécutable
chmod +x start.sh

# Configurer l'environnement
cp .env.example .env
nano .env  # Modifier les variables selon vos besoins

# Démarrer tous les services
./start.sh
```

### Installation manuelle

```bash
# Créer les répertoires
mkdir -p strapi n8n/workflows nginx/conf.d

# Modifier les permissions
chmod +x database/init/01-init-databases.sh

# Démarrer les services
docker-compose up -d --build

# Vérifier le statut
docker-compose ps
```

## ⚙️ Configuration

### 1. Configuration initiale des services

#### pgAdmin (Database Management)
1. Accédez à http://localhost:5050
2. Connectez-vous avec `PGADMIN_EMAIL` et `PGADMIN_PASSWORD`
3. Ajoutez une nouvelle connexion serveur :
   - Host: `postgres`
   - Port: `5432`
   - Username: Valeur de `POSTGRES_USER`
   - Password: Valeur de `POSTGRES_PASSWORD`

#### n8n (Workflow Automation)
1. Accédez à http://localhost:5678
2. Connectez-vous avec `N8N_BASIC_AUTH_USER` et `N8N_BASIC_AUTH_PASSWORD`
3. Configurez les credentials :
   - **PostgreSQL** : Host `postgres`, port `5432`
   - **Google APIs** : Ajoutez vos clés OAuth2
   - **Brevo API** : Ajoutez votre clé API
   - **OpenAI** : Ajoutez votre clé API

#### Metabase (Analytics)
1. Accédez à http://localhost:3000
2. Suivez l'assistant de configuration initiale
3. Configurez la connexion PostgreSQL :
   - Host: `postgres`
   - Port: `5432`
   - Database: `automation_hub`
   - Username/Password: Depuis votre `.env`

### 2. Configuration des APIs externes

#### Google APIs
```bash
# Dans votre .env
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_ADS_CUSTOMER_ID=your_google_ads_customer_id
GOOGLE_ANALYTICS_PROPERTY_ID=your_ga4_property_id
```

#### Brevo (Email Marketing)
```bash
# Dans votre .env
BREVO_API_KEY=your_brevo_api_key
BREVO_WEBHOOK_SECRET=your_brevo_webhook_secret
```

#### Réseaux Sociaux
```bash
# Facebook/Instagram
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret

# LinkedIn
LINKEDIN_CLIENT_ID=your_linkedin_client_id
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret
```

## 🔄 Workflows n8n

### Workflows inclus

1. **Collecte Brevo Email Events** (`brevo-email-events.json`)
   - Webhook pour événements email en temps réel
   - Stockage automatique dans PostgreSQL

2. **Collecte Google Analytics Quotidienne** (`google-analytics-daily.json`)
   - Récupération automatique des données GA4
   - Programmé quotidiennement à 3h du matin

3. **Analyse IA Hebdomadaire** (`ai-content-analysis.json`)
   - Analyse des performances marketing
   - Génération de recommandations IA
   - Suggestions de contenu automatiques

### Import des workflows

```bash
# Dans l'interface n8n
1. Aller dans "Workflows" → "Import from file"
2. Sélectionner les fichiers .json dans n8n/workflows/
3. Configurer les credentials nécessaires
4. Activer les workflows
```

### Workflow personnalisés suggérés

#### Collecte Google Ads
```javascript
// Node Schedule: Quotidien à 4h
// Node Google Ads API: Récupérer campagnes
// Node PostgreSQL: Insérer données
```

#### Monitoring SEO SerpBear
```javascript
// Node Schedule: Quotidien à 5h
// Node HTTP Request: API SerpBear
// Node PostgreSQL: Sauvegarder rankings
```

#### Social Media Automation
```javascript
// Node Schedule: Toutes les 4h
// Node Facebook/LinkedIn API
// Node PostgreSQL: Metrics storage
```

## 🗄️ Base de données

### Schéma `marketing_ops`

La base de données PostgreSQL contient un schéma dédié `marketing_ops` avec les tables suivantes :

#### Tables principales

| Table | Description | Colonnes clés |
|-------|-------------|---------------|
| `brevo_email_events` | Événements emails Brevo | event_type, email, campaign_id |
| `google_ads_data` | Données Google Ads | campaign_id, impressions, clicks, cost |
| `google_analytics_data` | Données GA4 | property_id, sessions, users, bounce_rate |
| `social_media_data` | Métriques réseaux sociaux | platform, engagement_rate, reach |
| `serpbear_rankings` | Positions SEO | keyword, position, domain |
| `leads` | Prospects et leads | email, score, status, source |
| `ai_content_suggestions` | Suggestions IA | content, type, confidence_score |

#### Exemple de requêtes utiles

```sql
-- Top 10 sources de trafic par sessions
SELECT traffic_source, AVG(sessions) as avg_sessions
FROM marketing_ops.google_analytics_data 
WHERE date_collected >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY traffic_source 
ORDER BY avg_sessions DESC 
LIMIT 10;

-- Évolution des positions SEO
SELECT keyword, AVG(position) as avg_position, 
       MIN(date_collected) as first_tracked,
       MAX(date_collected) as last_tracked
FROM marketing_ops.serpbear_rankings 
WHERE domain = 'votre-domaine.com'
GROUP BY keyword 
ORDER BY avg_position ASC;

-- Performance des campagnes email
SELECT event_type, COUNT(*) as count,
       DATE_TRUNC('day', event_date) as day
FROM marketing_ops.brevo_email_events 
WHERE event_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY event_type, day 
ORDER BY day DESC;
```

## 📊 Tableaux de bord Metabase

### Tableaux de bord suggérés

#### 1. Dashboard Marketing Overview
- Sessions GA4 par source
- Taux de conversion par campagne
- ROI publicitaire
- Évolution du trafic organique

#### 2. Dashboard Email Marketing
- Taux d'ouverture/clic par campagne
- Évolution des désabonnements
- Segmentation des audiences
- Performance par jour/heure

#### 3. Dashboard SEO Performance
- Positions moyennes par mot-clé
- Évolution du trafic organique
- Pages top performers
- Opportunités d'amélioration

#### 4. Dashboard Social Media
- Engagement par plateforme
- Croissance des abonnés
- Meilleur contenu par interactions
- Analyse sentiment (si configuré)

### Configuration Metabase

```sql
-- Connexion PostgreSQL dans Metabase
Host: postgres
Port: 5432
Database: automation_hub
Schema: marketing_ops
Username: [POSTGRES_USER]
Password: [POSTGRES_PASSWORD]
```

## 🔧 APIs et intégrations

### Configuration des webhooks

#### Brevo Webhook
URL: `http://votre-domaine.com:5678/webhook/brevo-webhook`
Events: `delivered`, `opened`, `clicked`, `bounced`, `unsubscribed`

#### Configuration Google APIs
1. Console Google Cloud → APIs & Services
2. Activer APIs : Analytics, Ads, Search Console
3. Créer credentials OAuth2
4. Configurer domaines autorisés

### Tests des intégrations

```bash
# Test webhook Brevo
curl -X POST http://localhost:5678/webhook/brevo-webhook \
  -H "Content-Type: application/json" \
  -d '{"event":"delivered","email":"test@example.com"}'

# Vérifier données en base
docker-compose exec postgres psql -U admin_user -d automation_hub \
  -c "SELECT * FROM marketing_ops.brevo_email_events ORDER BY created_at DESC LIMIT 5;"
```

## 🛡️ Sécurité

### Production checklist

- [ ] Changer tous les mots de passe par défaut
- [ ] Configurer HTTPS avec certificats SSL
- [ ] Limiter l'accès réseau (firewall)
- [ ] Backup automatique des données
- [ ] Monitoring des logs d'erreur
- [ ] Rotation des clés API
- [ ] Authentification 2FA quand possible

### Sauvegardes

```bash
# Backup PostgreSQL
docker-compose exec postgres pg_dump -U admin_user automation_hub > backup_$(date +%Y%m%d).sql

# Backup volumes Docker
docker run --rm -v strapi-automation-starter_postgres_data:/data -v $(pwd):/backup ubuntu tar czf /backup/postgres_backup.tar.gz /data
```

## 🐛 Dépannage

### Problèmes courants

#### Services ne démarrent pas
```bash
# Vérifier les logs
docker-compose logs [service_name]

# Redémarrer un service spécifique
docker-compose restart [service_name]

# Reconstruire si nécessaire
docker-compose up -d --build [service_name]
```

#### Problèmes de connexion base de données
```bash
# Vérifier que PostgreSQL est prêt
docker-compose exec postgres pg_isready -U admin_user

# Tester la connexion
docker-compose exec postgres psql -U admin_user -d automation_hub -c "SELECT version();"
```

#### n8n workflows en erreur
1. Vérifier les credentials dans n8n
2. Tester les connexions API
3. Vérifier les limites de taux des APIs
4. Consulter les logs détaillés

### Logs utiles

```bash
# Logs tous services
docker-compose logs -f

# Logs service spécifique
docker-compose logs -f n8n

# Logs base de données
docker-compose logs postgres | grep ERROR
```

## 📞 Support

### Monitoring recommandé

- **Uptime**: Configurer des checks de santé
- **Metrics**: Surveiller usage CPU/RAM
- **Alerts**: Email en cas d'erreur critique
- **Backup**: Vérification régulière des sauvegardes

### Ressources

- Documentation n8n: https://docs.n8n.io
- Documentation NocoDB: https://docs.nocodb.com
- Documentation Metabase: https://www.metabase.com/docs
- Documentation Strapi: https://docs.strapi.io

---

**Version**: 1.0.0  
**Dernière mise à jour**: Juin 2025  
**Licence**: MIT
