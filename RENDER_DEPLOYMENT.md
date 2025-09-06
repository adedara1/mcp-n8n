# Déploiement n8n-MCP sur Render.com

Ce guide explique comment déployer n8n-MCP Server avec support SSE et compatibilité n8n sur Render.com.

## 🚀 Déploiement Rapide

### Option 1: Déploiement automatique (Recommandé)

1. **Clonez ce dépôt** sur votre compte GitHub
2. **Connectez-vous** à [Render.com](https://dashboard.render.com)
3. **Importez** le dépôt GitHub
4. **Utilisez** le fichier `render.yaml` pour un déploiement automatique

### Option 2: Déploiement manuel

1. **Créez un nouveau Web Service** sur Render.com
2. **Connectez votre dépôt** GitHub
3. **Configurez** les paramètres suivants :

   ```
   Name: n8n-mcp-server
   Runtime: Node
   Build Command: npm run render:build
   Start Command: npm run render:start
   ```

## 📋 Configurations Disponibles

### 1. Serveur HTTP Standard
- **Start Command**: `npm run render:start`
- **Description**: Serveur MCP standard avec API HTTP
- **Port**: Défini automatiquement par Render.com

### 2. Serveur SSE (Server-Sent Events)
- **Start Command**: `npm run render:start:sse`
- **Description**: Support temps réel pour n8n MCP Server Trigger
- **Idéal pour**: Intégrations n8n avec événements temps réel

### 3. Mode Compatibilité n8n
- **Start Command**: `npm run render:start:compat`
- **Description**: Validation stricte des schémas pour n8n MCP Client Tool
- **Variables**: `N8N_COMPATIBILITY_MODE=true`

## 🔧 Variables d'Environnement

### Variables Obligatoires

```bash
# Token d'authentification sécurisé (REQUIS)
AUTH_TOKEN=your-secure-token-here

# Configuration de base
NODE_ENV=production
HOST=0.0.0.0
```

### Variables Optionnelles

```bash
# Configuration des logs
LOG_LEVEL=info

# CORS (pour API publique)
CORS_ORIGIN=*

# Proxy (Render.com utilise un proxy)
TRUST_PROXY=1

# Mode de compatibilité n8n
N8N_COMPATIBILITY_MODE=false

# Configuration n8n API (optionnel)
N8N_API_BASE_URL=https://your-n8n-instance.com/api/v1
N8N_API_KEY=your-n8n-api-key

# Serveur MCP
MCP_SERVER_NAME=n8n-mcp-render
MCP_SERVER_VERSION=2.10.8
```

## 🏗️ Architecture Multi-Services

Le fichier `render.yaml` configure trois services :

### 1. **n8n-mcp-server** (Port 3000)
- Serveur MCP standard
- API HTTP complète
- Monitoring de santé `/health`

### 2. **n8n-mcp-sse-server** (Port 3001)
- Support Server-Sent Events
- Streaming temps réel
- Idéal pour triggers n8n

### 3. **n8n-mcp-n8n-compat** (Port 3002)
- Mode compatibilité n8n stricte
- Schémas validation LangChain
- Support MCP Client Tool

## 📊 Monitoring et Santé

### Health Check
Tous les services exposent un endpoint de santé :
```
GET https://your-app.onrender.com/health
```

Réponse attendue :
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "version": "2.10.8",
  "mode": "http|sse",
  "database": "ready",
  "activeConnections": 0
}
```

### Logs
Les logs sont disponibles dans le dashboard Render.com :
- Niveau : INFO (production)
- Format : JSON structuré
- Inclusion : requêtes, erreurs, performances

## 🔐 Sécurité

### Génération du Token d'Authentification
```bash
# Méthode 1: OpenSSL
openssl rand -hex 32

# Méthode 2: Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### Configuration Sécurisée
1. **Définissez AUTH_TOKEN** dans les variables d'environnement Render
2. **Utilisez HTTPS** uniquement (automatique sur Render.com)
3. **Limitez CORS_ORIGIN** si nécessaire
4. **Activez TRUST_PROXY=1** pour les IPs correctes

## 🔌 Intégration n8n

### Configuration MCP Server Trigger (SSE)
```json
{
  "serverUrl": "https://your-sse-app.onrender.com/sse",
  "authToken": "your-secure-token",
  "compatibility": "sse"
}
```

### Configuration MCP Client Tool
```json
{
  "serverUrl": "https://your-compat-app.onrender.com/mcp",
  "authToken": "your-secure-token",
  "compatibility": "n8n-strict"
}
```

## 📁 Structure des Fichiers

```
├── render.yaml              # Configuration multi-services
├── Dockerfile.render        # Container optimisé
├── .env.render             # Variables par défaut
├── RENDER_DEPLOYMENT.md    # Ce guide
└── scripts/
    └── deploy-render.sh    # Script de déploiement
```

## 🛠️ Scripts de Déploiement

### Déploiement Automatique
```bash
npm run render:deploy
```

### Commandes Manuelles
```bash
# Construction
npm run render:build

# Démarrage (mode standard)
npm run render:start

# Démarrage (mode SSE)
npm run render:start:sse

# Démarrage (mode compatibilité n8n)
npm run render:start:compat
```

## 🔄 Mise à Jour

### Auto-déploiement
- **Activé** par défaut sur `main` branch
- **Déclenchement** : Push sur GitHub
- **Build time** : ~2-3 minutes

### Déploiement Manuel
1. Push vos changements sur GitHub
2. Dans Render dashboard → Manual Deploy
3. Ou utilisez `npm run render:deploy`

## 🐛 Dépannage

### Problèmes Courants

#### 1. Erreur de Build
```bash
# Vérifiez localement
npm run render:build

# Consultez les logs Render.com
```

#### 2. Service ne démarre pas
```bash
# Vérifiez les variables d'environnement
# AUTH_TOKEN doit être défini
```

#### 3. Health Check échoue
```bash
# Testez l'endpoint
curl https://your-app.onrender.com/health

# Vérifiez les logs pour erreurs
```

#### 4. Connexion SSE impossible
```bash
# Vérifiez le mode SSE
curl -H "Authorization: Bearer your-token" \
     https://your-sse-app.onrender.com/sse
```

### Support
- **Issues** : [GitHub Issues](https://github.com/your-repo/issues)
- **Documentation** : [README.md](./README.md)
- **SSE Guide** : [docs/SSE_IMPLEMENTATION.md](./docs/SSE_IMPLEMENTATION.md)

## 📈 Performance

### Ressources Recommandées
- **Plan** : Starter (512MB RAM)
- **Build time** : 2-3 minutes
- **Cold start** : ~30 secondes
- **Warm response** : <100ms

### Optimisations
- **Build cache** activé
- **Dependencies** optimisées pour production
- **Health checks** configurés
- **Scaling** automatique disponible

---

## ✅ Checklist de Déploiement

- [ ] Dépôt connecté à Render.com
- [ ] AUTH_TOKEN configuré
- [ ] Variables d'environnement définies
- [ ] Health check fonctionne
- [ ] Logs visibles dans dashboard
- [ ] API accessible via HTTPS
- [ ] Tests d'intégration n8n réussis

🎉 **Félicitations !** Votre serveur n8n-MCP est maintenant déployé sur Render.com avec support SSE et compatibilité n8n complète.