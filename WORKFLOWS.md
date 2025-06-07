# 🔄 Documentation des Workflows n8n

## 📋 Vue d'ensemble

Cette plateforme utilise **n8n** pour automatiser la collecte de données marketing et le monitoring des services. Chaque workflow est conçu pour être autonome et contribuer à l'écosystème global d'analytics et de surveillance.

## 🎯 Philosophie des Workflows

- **🔄 Automatisation complète** : Collecte automatique des données sans intervention manuelle
- **📊 Centralisation** : Toutes les données convergent vers PostgreSQL
- **⚡ Temps réel** : Monitoring continu et alertes instantanées
- **🧠 Intelligence** : Analyse IA des données pour des insights actionnables
- **🔗 Intégration** : Connexion fluide entre tous les services

---

## 📊 Workflows Existants

### 1. 📈 Google Analytics Daily (`google-analytics-daily.json`)

**🎯 Objectif :** Collecte quotidienne des données Google Analytics pour alimenter les rapports de performance.

**⏰ Fréquence :** Tous les jours à 3h du matin

**🔗 Services connectés :**
- Google Analytics API
- PostgreSQL (`marketing_ops.google_analytics_data`)

**📋 Données collectées :**
- Sessions, utilisateurs, nouveaux utilisateurs
- Pages vues, taux de rebond
- Durée moyenne des sessions
- Sources de trafic et catégories d'appareils
- Données géographiques (pays)

**🔄 Flux d'exécution :**
```
Planificateur (3h) → Google Analytics API → Traitement des données → PostgreSQL
```

**💾 Structure des données :**
```sql
-- Table: marketing_ops.google_analytics_data
property_id TEXT,
date_collected DATE,
traffic_source TEXT,
device_category TEXT,
country TEXT,
sessions INTEGER,
users INTEGER,
new_users INTEGER,
page_views INTEGER,
bounce_rate FLOAT,
avg_session_duration FLOAT,
metric_name TEXT,
metric_value INTEGER,
raw_data JSONB
```

---

### 2. 📧 Brevo Email Events (`brevo-email-events.json`)

**🎯 Objectif :** Capture en temps réel des événements email (envois, ouvertures, clics, bounces) via webhook.

**⏰ Fréquence :** Temps réel (webhook)

**🔗 Services connectés :**
- Brevo (via webhook)
- PostgreSQL (`marketing_ops.brevo_email_events`)

**📋 Événements trackés :**
- Envois d'emails
- Ouvertures
- Clics sur liens
- Bounces (échecs de livraison)
- Désinscriptions

**🔄 Flux d'exécution :**
```
Webhook Brevo → Formatage des données → PostgreSQL → Réponse de confirmation
```

**💾 Structure des données :**
```sql
-- Table: marketing_ops.brevo_email_events
event_type TEXT,
email TEXT,
subject TEXT,
campaign_id TEXT,
message_id TEXT,
recipient_email TEXT,
tags JSONB,
event_date TIMESTAMP
```

---

### 3. 🔍 SerpBear Rankings (`serpbear-rankings.json`)

**🎯 Objectif :** Collecte des positions SEO des mots-clés suivis pour monitorer le référencement.

**⏰ Fréquence :** Configuration à définir dans SerpBear

**🔗 Services connectés :**
- SerpBear API
- PostgreSQL (`marketing_ops.serpbear_rankings`)

**📋 Données collectées :**
- Positions des mots-clés
- Domaines surveillés
- Évolution du ranking
- Métadonnées de suivi

**🔄 Flux d'exécution :**
```
SerpBear API → Traitement positions → PostgreSQL
```

**💾 Structure des données :**
```sql
-- Table: marketing_ops.serpbear_rankings
keyword TEXT,
position INTEGER,
domain TEXT,
date_collected DATE,
search_engine TEXT,
location TEXT,
device_type TEXT
```

---

### 4. 🤖 AI Content Analysis (`ai-content-analysis.json`)

**🎯 Objectif :** Analyse hebdomadaire automatique des performances marketing avec génération de recommandations IA.

**⏰ Fréquence :** Hebdomadaire (lundi 9h)

**🔗 Services connectés :**
- PostgreSQL (lecture des données analytics, SEO, social)
- OpenAI API
- PostgreSQL (`marketing_ops.ai_insights`)

**📋 Analyses générées :**
- Synthèse des performances hebdomadaires
- 3 recommandations d'amélioration
- 5 idées de contenu basées sur les données
- Tendances et insights actionnables

**🔄 Flux d'exécution :**
```
Planificateur → Agrégation des données → Prompt IA → OpenAI → Sauvegarde insights
```

**🧠 Intelligence artificielle :**
- Analyse croisée des données GA, SEO et réseaux sociaux
- Génération de recommandations personnalisées
- Identification des opportunités d'amélioration
- Suggestions de contenu basées sur les performances

---

### 5. 🌐 Website Monitoring (`website-monitoring.json`)

**🎯 Objectif :** Surveillance continue de la disponibilité et des performances des services de la plateforme.

**⏰ Fréquence :** Toutes les 15 minutes

**🔗 Services surveillés :**
- `http://website:3000` (Site Nuxt)
- `http://strapi:1337` (CMS Strapi)
- `http://nocodb:8080` (Interface NocoDB)
- `http://n8n:5678` (n8n)
- `http://metabase:3000` (Analytics Metabase)
- `http://serpbear:3000` (Monitoring SEO)

**📋 Métriques collectées :**
- Code de statut HTTP
- Temps de réponse
- Taille du contenu
- Titre de la page
- Statut de disponibilité
- Validation SSL

**🔄 Flux d'exécution :**
```
Planificateur (15min) → Test chaque URL → Traitement réponse → PostgreSQL → Alertes si erreur
```

**🚨 Système d'alertes :**
- Détection automatique des pannes
- Formatage des messages d'alerte
- Notification en temps réel

**💾 Structure des données :**
```sql
-- Table: marketing_ops.website_content_monitor
url_checked TEXT,
http_status_code INTEGER,
response_time INTEGER,
content_length INTEGER,
extracted_title TEXT,
is_available BOOLEAN,
error_message TEXT,
fetch_timestamp TIMESTAMP,
ssl_valid BOOLEAN
```

---

## 🚀 Workflows Supplémentaires Recommandés

### 6. 📱 Social Media Performance Monitor

**🎯 Objectif :** Collecte automatique des métriques des réseaux sociaux.

**⏰ Fréquence :** Quotidienne (5h du matin)

**🔗 APIs à intégrer :**
- Facebook/Instagram Graph API
- Twitter API v2
- LinkedIn API
- YouTube Analytics API

**📊 Métriques :**
- Followers, engagement rate
- Likes, commentaires, partages
- Reach et impressions
- Clics sur liens

---

### 7. 💰 E-commerce Analytics (si applicable)

**🎯 Objectif :** Suivi des ventes et conversions e-commerce.

**⏰ Fréquence :** Temps réel + résumé quotidien

**📊 Métriques :**
- Revenus, commandes, panier moyen
- Taux de conversion
- Produits les plus vendus
- Abandons de panier

---

### 8. 🔒 Security & Performance Alerts

**🎯 Objectif :** Monitoring avancé de la sécurité et des performances.

**⏰ Fréquence :** Continue

**🔍 Surveillances :**
- Tentatives d'intrusion
- Charge serveur
- Erreurs 404 fréquentes
- Temps de réponse anormaux

---

### 9. 📋 Content Audit & SEO Health Check

**🎯 Objectif :** Audit automatique du contenu et de la santé SEO.

**⏰ Fréquence :** Hebdomadaire

**🔍 Vérifications :**
- Pages sans meta description
- Contenu dupliqué
- Liens cassés
- Images sans alt text

---

### 10. 💬 Customer Feedback Aggregator

**🎯 Objectif :** Centralisation des retours clients de toutes sources.

**⏰ Fréquence :** Temps réel

**📥 Sources :**
- Formulaires de contact
- Avis Google/Facebook
- Support client
- Enquêtes de satisfaction

---

## 🛠️ Configuration et Maintenance

### Variables d'environnement requises

```env
# Google Analytics
GOOGLE_ANALYTICS_PROPERTY_ID=GA4_PROPERTY_ID

# OpenAI
OPENAI_API_KEY=sk-xxx

# Base de données
POSTGRES_HOST=postgres
POSTGRES_DB=marketing_ops
POSTGRES_USER=n8n_user
POSTGRES_PASSWORD=secure_password

# Brevo
BREVO_WEBHOOK_SECRET=webhook_secret
```

### Credentials n8n requis

1. **Google Analytics OAuth2** (`google-analytics-oauth`)
2. **PostgreSQL Main** (`postgres-main`)
3. **OpenAI API** (`openai-api`)

### Monitoring des workflows

- **Logs centralisés** dans n8n
- **Alertes d'échec** configurables
- **Métriques de performance** suivies
- **Historique d'exécution** conservé

---

## 📈 Tableaux de bord et visualisations

### Metabase Dashboards recommandés

1. **🎯 Marketing Performance Overview**
   - GA metrics + SEO positions
   - Tendances sur 30 jours
   - Comparaisons périodiques

2. **📧 Email Marketing Dashboard**
   - Taux d'ouverture/clic par campagne
   - Évolution des performances
   - Segmentation des audiences

3. **🔍 SEO Monitoring Dashboard**
   - Évolution des positions
   - Mots-clés gagnants/perdants
   - Opportunités d'amélioration

4. **🌐 Infrastructure Health Dashboard**
   - Disponibilité des services
   - Temps de réponse
   - Alertes et incidents

5. **🧠 AI Insights Dashboard**
   - Recommandations générées
   - Suivi des actions mises en place
   - ROI des optimisations

---

## 🔧 Maintenance et évolutions

### Actions de maintenance régulières

- **Nettoyage des données** anciennes (>6 mois)
- **Optimisation des requêtes** PostgreSQL
- **Mise à jour des credentials** API
- **Test des workflows** de backup

### Évolutions prévues

- **Machine Learning** pour prédictions
- **Automatisation marketing** avancée
- **Intégrations CRM** (HubSpot, Salesforce)
- **Analyse de sentiment** des retours clients

---

## 📞 Support et dépannage

### Logs et debugging

```bash
# Voir les logs n8n
docker-compose logs n8n

# Vérifier la base de données
docker-compose exec postgres psql -U postgres -d marketing_ops
```

### Points de vérification

1. **Connectivité APIs** - Credentials valides
2. **Espace disque** - PostgreSQL et logs
3. **Performances** - Temps d'exécution des workflows
4. **Données** - Cohérence et qualité

---

*Cette documentation évolue avec la plateforme. Dernière mise à jour : juin 2025*
