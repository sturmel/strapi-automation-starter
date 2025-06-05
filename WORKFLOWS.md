# 🔄 Guide des Workflows n8n

Ce document détaille tous les workflows automatisés inclus dans le Marketing Automation Hub.

## 📋 Workflows Inclus

### 1. **Brevo Email Events** (`brevo-email-events.json`)

**Objectif** : Capturer en temps réel tous les événements emails depuis Brevo

**Déclencheur** : Webhook HTTP (`/webhook/brevo-webhook`)

**Actions** :
- Réception des événements Brevo (delivered, opened, clicked, bounced, etc.)
- Formatage et nettoyage des données
- Stockage dans `marketing_ops.brevo_email_events`

**Configuration requise** :
```bash
# Dans Brevo, configurez le webhook vers :
URL: http://votre-domaine.com:5678/webhook/brevo-webhook
Events: delivered, opened, clicked, bounced, unsubscribed, spam, invalid
```

**Structure des données stockées** :
- `event_type` : Type d'événement (delivered, opened, etc.)
- `email` : Email du destinataire
- `campaign_id` : ID de la campagne
- `event_date` : Date/heure de l'événement
- `tags` : Métadonnées supplémentaires (JSON)

---

### 2. **Google Analytics Daily** (`google-analytics-daily.json`)

**Objectif** : Collecte quotidienne des données Google Analytics 4

**Déclencheur** : Cron (tous les jours à 3h du matin)

**Actions** :
- Récupération des métriques GA4 (sessions, utilisateurs, pages vues)
- Segmentation par source de trafic, device, pays
- Stockage dans `marketing_ops.google_analytics_data`

**Métriques collectées** :
- Sessions, utilisateurs, nouveaux utilisateurs
- Pages vues, taux de rebond
- Durée moyenne des sessions
- Objectifs et conversions

**Configuration requise** :
1. Activer l'API Google Analytics dans Google Cloud Console
2. Créer des credentials OAuth2
3. Configurer la variable `GOOGLE_ANALYTICS_PROPERTY_ID`

---

### 3. **AI Content Analysis** (`ai-content-analysis.json`)

**Objectif** : Analyse hebdomadaire des performances et génération de recommandations IA

**Déclencheur** : Cron (tous les lundis à 9h)

**Actions** :
1. Récupération des données des 7 derniers jours (Analytics, SEO, Social)
2. Compilation d'un rapport de performance
3. Envoi à OpenAI GPT-4 pour analyse
4. Génération de recommandations et idées de contenu
5. Stockage dans `marketing_ops.ai_content_suggestions`

**Types de suggestions générées** :
- Recommandations d'optimisation
- Idées de contenu basées sur les données
- Analyses de tendances
- Suggestions d'amélioration SEO

---

### 4. **SerpBear Rankings** (`serpbear-rankings.json`)

**Objectif** : Collecte quotidienne des positions SEO depuis SerpBear

**Déclencheur** : Cron (tous les jours à 5h du matin)

**Actions** :
- Récupération des positions via l'API SerpBear
- Calcul des changements par rapport à la veille
- Stockage dans `marketing_ops.serpbear_rankings`

**Données collectées** :
- Position actuelle par mot-clé
- Changements de position
- Volume de recherche
- Difficulté du mot-clé
- URL positionnée

---

### 5. **Website Monitoring** (`website-monitoring.json`)

**Objectif** : Surveillance continue de la disponibilité des services

**Déclencheur** : Cron (toutes les 15 minutes)

**Actions** :
- Test de disponibilité de tous les services
- Mesure du temps de réponse
- Détection des erreurs
- Alertes en cas de problème

**Services surveillés** :
- Site web Nuxt3
- Strapi CMS
- NocoDB
- n8n
- Metabase
- SerpBear

---

## 🔧 Installation des Workflows

### 1. Accès à n8n
```bash
# Ouvrir n8n dans le navigateur
http://localhost:5678

# Identifiants par défaut (modifiables dans .env)
Utilisateur: admin
Mot de passe: n8n_secure_password_2024!
```

### 2. Configuration des Credentials

#### PostgreSQL
```
Type: PostgreSQL
Host: postgres
Port: 5432
Database: automation_hub
Schema: marketing_ops
Username: [POSTGRES_USER]
Password: [POSTGRES_PASSWORD]
```

#### Google APIs
```
Type: Google OAuth2 API
Scopes: 
- https://www.googleapis.com/auth/analytics.readonly
- https://www.googleapis.com/auth/adwords
Client ID: [GOOGLE_CLIENT_ID]
Client Secret: [GOOGLE_CLIENT_SECRET]
```

#### OpenAI
```
Type: OpenAI
API Key: [OPENAI_API_KEY]
```

#### HTTP Authentication (pour SerpBear)
```
Type: Header Auth
Name: Authorization
Value: Bearer [SERPBEAR_API_KEY]
```

### 3. Import des Workflows

1. Dans n8n, aller à **Workflows** > **Import from file**
2. Sélectionner les fichiers `.json` du dossier `n8n/workflows/`
3. Pour chaque workflow :
   - Vérifier les credentials
   - Tester les connexions
   - Activer le workflow

---

## 📊 Workflows Personnalisés Suggérés

### Social Media Collector
```json
{
  "trigger": "Schedule (every 4 hours)",
  "actions": [
    "Facebook Pages API - Get page insights",
    "Instagram Basic Display API - Get media insights", 
    "LinkedIn Pages API - Get page statistics",
    "Transform and clean data",
    "Insert into marketing_ops.social_media_data"
  ]
}
```

### Lead Scoring Automation
```json
{
  "trigger": "Database trigger on new lead",
  "actions": [
    "Get lead activity history",
    "Calculate engagement score",
    "Apply ML scoring model",
    "Update lead score",
    "Trigger actions if score > threshold"
  ]
}
```

### Email Campaign Optimizer
```json
{
  "trigger": "Schedule (weekly)",
  "actions": [
    "Analyze email performance data",
    "Identify best performing subject lines",
    "Generate A/B test suggestions",
    "Create optimized campaign templates"
  ]
}
```

---

## 🐛 Dépannage des Workflows

### Erreurs Communes

#### Credentials invalides
```bash
# Vérifier dans n8n > Settings > Credentials
# Re-autoriser les APIs OAuth si nécessaire
```

#### Limites de taux API
```bash
# Google Analytics : 100 requêtes/100 secondes
# Brevo : Variable selon le plan
# OpenAI : Limite par minute selon le plan
```

#### Erreurs de base de données
```bash
# Vérifier la connectivité PostgreSQL
docker-compose exec postgres pg_isready -U admin_user

# Vérifier les permissions sur le schéma
docker-compose exec postgres psql -U admin_user -d automation_hub \
  -c "SELECT has_schema_privilege('marketing_ops', 'USAGE');"
```

### Monitoring des Workflows

#### Via n8n Interface
- **Executions** : Historique des exécutions
- **Logs** : Détails des erreurs
- **Manual trigger** : Test manuel

#### Via Base de Données
```sql
-- Vérifier les dernières exécutions de workflows
SELECT 
  table_name,
  MAX(created_at) as last_update,
  COUNT(*) as records_today
FROM information_schema.tables t
JOIN marketing_ops.brevo_email_events b ON true
WHERE table_schema = 'marketing_ops'
  AND created_at >= CURRENT_DATE
GROUP BY table_name;
```

---

## 📈 Optimisations et Bonnes Pratiques

### Performance
- **Batch processing** : Traiter les données par lots
- **Incremental updates** : Récupérer seulement les nouvelles données
- **Error handling** : Gestion robuste des erreurs
- **Retry logic** : Nouvelles tentatives automatiques

### Sécurité
- **API Keys** : Rotation régulière des clés
- **Permissions** : Accès minimal nécessaire
- **Logs** : Surveillance des accès suspects
- **Backup** : Sauvegarde des workflows critiques

### Monitoring
```sql
-- Query pour surveiller la santé des workflows
SELECT 
  'brevo_events' as source,
  COUNT(*) as records_last_24h
FROM marketing_ops.brevo_email_events 
WHERE created_at >= NOW() - INTERVAL '24 hours'
UNION ALL
SELECT 
  'google_analytics' as source,
  COUNT(*) as records_last_24h
FROM marketing_ops.google_analytics_data 
WHERE created_at >= NOW() - INTERVAL '24 hours';
```

---

**Version** : 1.0.0  
**Dernière mise à jour** : Juin 2025
