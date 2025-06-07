# ⚙️ Guide de Configuration des Workflows n8n

## 🎯 Vue d'ensemble

Ce guide détaille la configuration complète des workflows n8n pour la plateforme Strapi Automation Starter. Chaque workflow est conçu pour être autonome tout en s'intégrant parfaitement dans l'écosystème global.

---

## 🗄️ Configuration de la Base de Données

### 1. Initialisation du Schéma

```bash
# Exécuter le script de création du schéma
docker-compose exec postgres psql -U postgres -d marketing_ops -f /path/to/marketing_ops_schema.sql
```

### 2. Variables d'Environnement Requises

Ajouter dans votre fichier `.env` :

```env
# Base de données
POSTGRES_HOST=postgres
POSTGRES_DB=marketing_ops
POSTGRES_USER=n8n_user
POSTGRES_PASSWORD=secure_password

# Google Analytics
GOOGLE_ANALYTICS_PROPERTY_ID=GA4_PROPERTY_ID

# OpenAI pour l'analyse IA
OPENAI_API_KEY=sk-xxxxxxxxxxxxx

# Brevo Email
BREVO_API_KEY=xkeysib-xxxxxxxxxxxxx
BREVO_WEBHOOK_SECRET=webhook_secret_123

# Social Media APIs
FACEBOOK_PAGE_ID=your_facebook_page_id
TWITTER_USER_ID=your_twitter_user_id
YOUTUBE_CHANNEL_ID=your_youtube_channel_id

# Website monitoring
WEBSITE_URL=https://your-website.com

# SerpBear
SERPBEAR_API_KEY=your_serpbear_api_key
SERPBEAR_DOMAIN=your-domain.com
```

---

## 🔑 Configuration des Credentials n8n

### 1. Google Analytics OAuth2

```json
{
  "name": "Google Analytics OAuth2",
  "type": "googleAnalyticsOAuth2Api",
  "data": {
    "clientId": "your-client-id",
    "clientSecret": "your-client-secret"
  }
}
```

**Étapes de configuration :**
1. Aller sur [Google Cloud Console](https://console.cloud.google.com)
2. Créer un projet ou sélectionner un existant
3. Activer l'API Google Analytics Reporting
4. Créer des credentials OAuth 2.0
5. Ajouter `http://localhost:5678/rest/oauth2-credential/callback` dans les URIs de redirection

### 2. PostgreSQL Main

```json
{
  "name": "PostgreSQL Main",
  "type": "postgres",
  "data": {
    "host": "postgres",
    "port": 5432,
    "database": "marketing_ops",
    "user": "n8n_user",
    "password": "secure_password",
    "ssl": false
  }
}
```

### 3. OpenAI API

```json
{
  "name": "OpenAI API",
  "type": "openAiApi",
  "data": {
    "apiKey": "sk-xxxxxxxxxxxxx"
  }
}
```

### 4. Social Media Credentials

#### Facebook Graph API
```json
{
  "name": "Facebook Graph API",
  "type": "facebookGraphApi",
  "data": {
    "accessToken": "your-facebook-access-token"
  }
}
```

#### Twitter OAuth2
```json
{
  "name": "Twitter OAuth2",
  "type": "twitterOAuth2Api",
  "data": {
    "clientId": "your-twitter-client-id",
    "clientSecret": "your-twitter-client-secret"
  }
}
```

#### YouTube OAuth2
```json
{
  "name": "YouTube OAuth2",
  "type": "youTubeOAuth2Api",
  "data": {
    "clientId": "your-youtube-client-id",
    "clientSecret": "your-youtube-client-secret"
  }
}
```

---

## 📥 Import des Workflows

### 1. Workflows Principaux

Copier les fichiers JSON des workflows dans n8n :

```bash
# Copier tous les workflows
cp n8n/workflows/*.json /path/to/n8n/workflows/
```

### 2. Ordre d'Activation Recommandé

1. **Website Monitoring** - Pour s'assurer que tous les services fonctionnent
2. **Google Analytics Daily** - Collecte des données de base
3. **Brevo Email Events** - Activation des webhooks
4. **SerpBear Rankings** - Monitoring SEO
5. **AI Content Analysis** - Analyse hebdomadaire
6. **Social Media Performance** - Métriques réseaux sociaux
7. **Content Audit SEO** - Audit hebdomadaire
8. **Security Performance Monitor** - Surveillance système

---

## 🔄 Configuration Spécifique par Workflow

### 1. Google Analytics Daily

**Paramètres à vérifier :**
- `GOOGLE_ANALYTICS_PROPERTY_ID` dans les variables d'environnement
- Credentials Google Analytics OAuth2 configurés
- Plage de dates : hier (`{{ $today.minus({days: 1}).toFormat('yyyy-MM-dd') }}`)

**Dimensions collectées :**
- date
- sessionSource  
- deviceCategory
- country

**Métriques collectées :**
- sessions
- users
- newUsers
- pageviews
- bounceRate
- averageSessionDuration

### 2. Brevo Email Events

**Configuration Webhook :**
```bash
# URL du webhook à configurer dans Brevo
https://your-n8n-domain.com/webhook/brevo-webhook
```

**Événements à configurer dans Brevo :**
- sent
- delivered
- open
- click
- bounce
- blocked
- spam
- unsubscribe

### 3. SerpBear Rankings

**Configuration API :**
- Endpoint : `http://serpbear:3000/api/keywords`
- Authentification via API key
- Collecte automatique selon la fréquence SerpBear

### 4. AI Content Analysis

**Prompt Template :**
```javascript
const prompt = `Analyse marketing hebdomadaire:

Données Analytics (7 derniers jours):
${analyticsData.map(d => `- ${d.traffic_source}: ${d.avg_sessions} sessions moyennes, ${d.avg_bounce_rate}% bounce rate`).join('\n')}

Performances SEO (top keywords):
${seoData.map(d => `- "${d.keyword}": position ${d.avg_position} sur ${d.domain}`).join('\n')}

Réseaux sociaux:
${socialData.map(d => `- ${d.platform}: ${d.avg_engagement}% engagement, ${d.total_interactions} interactions`).join('\n')}

Génère 3 recommandations d'amélioration et 5 idées de contenu basées sur ces données. Format JSON avec {recommendations: [], content_ideas: []}.`;
```

### 5. Website Monitoring

**URLs surveillées par défaut :**
```json
[
  "http://website:3000",
  "http://strapi:1337", 
  "http://nocodb:8080",
  "http://n8n:5678",
  "http://metabase:3000",
  "http://serpbear:3000"
]
```

**Seuils d'alerte :**
- Temps de réponse > 3000ms : Warning
- Temps de réponse > 5000ms : Critical
- Service indisponible : Critical

---

## 📊 Configuration des Tableaux de Bord

### 1. Metabase - Connexion PostgreSQL

```json
{
  "name": "Marketing Ops Database",
  "engine": "postgres",
  "details": {
    "host": "postgres",
    "port": 5432,
    "dbname": "marketing_ops",
    "user": "metabase_user",
    "password": "metabase_password"
  }
}
```

### 2. Dashboards Recommandés

#### Marketing Performance Overview
- **Métriques GA** : Sessions, utilisateurs, taux de rebond
- **SEO Performance** : Évolution des positions
- **Email Marketing** : Taux d'ouverture, clics
- **Tendances** : Comparaisons sur 30 jours

#### Infrastructure Health
- **Disponibilité** : Uptime par service
- **Performance** : Temps de réponse moyens
- **Alertes** : Incidents récents
- **Ressources** : Utilisation CPU/RAM

#### SEO & Content Audit
- **Score santé SEO** : Évolution dans le temps
- **Problèmes détectés** : Par type et gravité
- **Actions prioritaires** : Checklist
- **Performance mots-clés** : Top 10 et tendances

---

## 🚨 Configuration des Alertes

### 1. Webhook d'Alertes (optionnel)

Pour recevoir les alertes par Slack/Discord :

```javascript
// Node webhook d'alerte personnalisé
const alertData = $json;
const webhookUrl = "https://hooks.slack.com/your-webhook-url";

const message = {
  text: alertData.alert_message,
  attachments: [{
    color: alertData.severity === 'critical' ? 'danger' : 'warning',
    fields: [{
      title: "Gravité",
      value: alertData.severity,
      short: true
    }, {
      title: "Timestamp", 
      value: new Date().toLocaleString('fr-FR'),
      short: true
    }]
  }]
};

return {
  json: {
    url: webhookUrl,
    body: JSON.stringify(message),
    headers: {
      "Content-Type": "application/json"
    }
  }
};
```

### 2. Configuration Email SMTP

Pour les alertes par email :

```json
{
  "name": "SMTP Email",
  "type": "smtp",
  "data": {
    "host": "smtp.gmail.com",
    "port": 587,
    "secure": false,
    "user": "your-email@gmail.com", 
    "password": "your-app-password"
  }
}
```

---

## 🔧 Maintenance et Monitoring

### 1. Nettoyage Automatique des Données

Créer un workflow de maintenance mensuel :

```sql
-- Exécuter le nettoyage automatique
SELECT marketing_ops.cleanup_old_data(6); -- Garder 6 mois de données
```

### 2. Monitoring des Workflows

Ajouter dans chaque workflow un node de logging :

```javascript
// Node de logging des exécutions
const executionData = {
  workflow_id: $workflow.id,
  workflow_name: $workflow.name,
  execution_id: $execution.id,
  status: 'success', // ou 'error'
  start_time: $execution.startTime,
  end_time: new Date().toISOString(),
  items_processed: $input.all().length,
  execution_data: {
    totalTime: Date.now() - new Date($execution.startTime).getTime(),
    memory: process.memoryUsage()
  }
};

return [{ json: executionData }];
```

### 3. Vérifications de Santé

Créer un workflow de vérification quotidien :

```javascript
// Vérification de la santé des workflows
const healthChecks = [
  { 
    name: 'Google Analytics',
    lastRun: '2025-06-07T03:00:00Z',
    status: 'success',
    dataPoints: 150
  },
  // ... autres workflows
];

const overallHealth = healthChecks.every(check => 
  check.status === 'success' && 
  Date.now() - new Date(check.lastRun).getTime() < 25 * 60 * 60 * 1000 // 25h
);

return [{
  json: {
    overall_status: overallHealth ? 'healthy' : 'warning',
    checks: healthChecks,
    last_check: new Date().toISOString()
  }
}];
```

---

## 🚀 Optimisations et Bonnes Pratiques

### 1. Gestion des Erreurs

Toujours configurer `continueOnFail: true` pour les nodes critiques :

```json
{
  "parameters": {
    // ... paramètres du node
  },
  "continueOnFail": true,
  "onError": "continueRegularOutput"
}
```

### 2. Limitation du Débit

Pour les APIs avec des limites :

```javascript
// Attendre entre les appels API
await new Promise(resolve => setTimeout(resolve, 1000)); // 1 seconde
```

### 3. Cache des Données

Utiliser Redis pour le cache des données fréquemment accédées :

```javascript
// Cache Redis simple
const cacheKey = `analytics_${date}`;
const cachedData = await redis.get(cacheKey);

if (cachedData) {
  return JSON.parse(cachedData);
} else {
  // Récupérer depuis l'API
  const freshData = await fetchAnalyticsData();
  await redis.setex(cacheKey, 3600, JSON.stringify(freshData)); // Cache 1h
  return freshData;
}
```

---

## 📞 Dépannage

### Problèmes Courants

1. **Credentials expirés**
   - Vérifier la validité des tokens OAuth
   - Renouveler les credentials si nécessaire

2. **Limites d'API atteintes**
   - Ajuster la fréquence des workflows
   - Implémenter des pauses entre les appels

3. **Erreurs de base de données**
   - Vérifier la connectivité PostgreSQL
   - Contrôler l'espace disque disponible

4. **Performances dégradées**
   - Analyser les logs d'exécution
   - Optimiser les requêtes SQL
   - Ajuster les ressources Docker

### Logs et Debugging

```bash
# Logs n8n
docker-compose logs -f n8n

# Logs PostgreSQL
docker-compose logs -f postgres

# Vérifier l'espace disque
docker system df

# Nettoyer les données Docker
docker system prune -a
```

---

## 📈 Évolutions Futures

### Intégrations Prévues

1. **CRM Integration** (HubSpot, Salesforce)
2. **Advanced Analytics** (Machine Learning predictions)
3. **Customer Journey Tracking**
4. **Automated Marketing Campaigns**
5. **Real-time Personalization**

### Améliorations Techniques

1. **Clustering n8n** pour la haute disponibilité
2. **Message Queue** (Redis/RabbitMQ) pour la scalabilité
3. **ML Pipeline** pour les prédictions automatiques
4. **API Gateway** pour la gestion des accès

---

*Documentation mise à jour : Juin 2025*
*Version des workflows : 1.0*
