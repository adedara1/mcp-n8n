# Render.com Deployment Guide

Complete guide for deploying n8n-MCP to Render.com with one-click deployment and advanced configuration options.

## 🚀 Quick Deploy (Recommended)

The fastest way to get n8n-MCP running on Render:

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/adedara1/mcp-n8n)

### Step 1: Deploy to Render

1. Click the "Deploy to Render" button above
2. Sign in to your Render account (create one if needed - free tier available)
3. Configure your service:
   - **Repository**: `https://github.com/adedara1/mcp-n8n` (auto-filled)
   - **Service Name**: `n8n-mcp` (or your preferred name)
   - **Region**: Choose the closest to your location for best performance
   - **Branch**: `main`
   - **Plan**: Start with "Free" (can upgrade later)

### Step 2: Configure Environment Variables

Render will automatically configure most settings. You only need to set:

**Required Variables:**
- **AUTH_TOKEN**: Click "Generate Value" for automatic secure token generation

**Optional Variables (for n8n integration):**
- **N8N_API_URL**: Your n8n instance URL (e.g., `https://your-n8n.example.com`)
- **N8N_API_KEY**: Your n8n API key from Settings > API

### Step 3: Deploy and Wait

1. Click "Deploy"
2. Wait 3-5 minutes for the initial deployment
3. Your service will be available at `https://your-service-name.onrender.com`

## 🔧 Claude Desktop Configuration

### Method 1: HTTP Client (Recommended)

Add this to your Claude Desktop configuration:

```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["@modelcontextprotocol/client-http"],
      "env": {
        "MCP_SERVER_URL": "https://your-service.onrender.com",
        "MCP_AUTH_TOKEN": "your-generated-auth-token"
      }
    }
  }
}
```

### Method 2: MCP-Remote (Alternative)

```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["mcp-remote", "https://your-service.onrender.com", "your-auth-token"]
    }
  }
}
```

**Configuration file locations:**
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`

## 📋 Manual Deployment (Advanced)

If you need custom configuration, you can deploy manually:

### Step 1: Fork the Repository

1. Fork the repository to your GitHub account
2. Clone your fork locally
3. Make any necessary customizations

### Step 2: Create Render Service

1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click "New +" → "Web Service"
3. Connect your GitHub account and select your fork
4. Configure the service:
   - **Name**: Your preferred service name
   - **Region**: Select optimal region
   - **Branch**: `main`
   - **Build Command**: Leave empty (uses Dockerfile)
   - **Start Command**: Leave empty (uses Dockerfile CMD)

### Step 3: Configure Environment Variables

Set these environment variables in the Render dashboard:

```bash
# Required
MCP_MODE=http
USE_FIXED_HTTP=true
HOST=0.0.0.0
PORT=3000
CORS_ORIGIN=*
TRUST_PROXY=1
LOG_LEVEL=info
NODE_ENV=production
REBUILD_ON_START=false

# Security (generate secure token)
AUTH_TOKEN=your-secure-token-here

# Optional n8n integration
N8N_API_URL=https://your-n8n-instance.com
N8N_API_KEY=your-n8n-api-key
```

### Step 4: Add Persistent Storage

1. In service settings, go to "Disks"
2. Add a new disk:
   - **Name**: `n8n-mcp-data`
   - **Mount Path**: `/app/data`
   - **Size**: 1GB (minimum)

## 🔍 Health Monitoring

Your deployed service includes several monitoring endpoints:

- **Health Check**: `https://your-service.onrender.com/health`
- **Service Info**: `https://your-service.onrender.com/info`
- **Logs**: Available in Render dashboard

### Health Check Response

```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "2.10.8",
  "mode": "http",
  "database": {
    "status": "connected",
    "nodes": 535,
    "size": "15.2MB"
  }
}
```

## ⚡ Performance Optimization

### Free Tier Considerations

- Services sleep after 15 minutes of inactivity
- First request after sleep takes 10-15 seconds (cold start)
- 750 hours/month usage limit

### Upgrading for Production

For production use, consider upgrading to a paid plan:

- **Starter Plan ($7/month)**:
  - Always-on service (no sleeping)
  - Faster cold starts
  - More CPU and memory

- **Standard Plan ($25/month)**:
  - Higher performance
  - More concurrent connections
  - Priority support

## 🔧 Advanced Configuration

### Custom Dockerfile

If you need to customize the Docker build, you can use the included `Dockerfile.render`:

1. In your fork, rename `Dockerfile.render` to `Dockerfile`
2. Customize as needed
3. Redeploy your service

### Environment-Specific Settings

The service automatically detects Render environment and applies optimizations:

```bash
# Automatically set by Render
RENDER=true
RENDER_SERVICE_ID=srv-xxx
RENDER_SERVICE_NAME=your-service-name
RENDER_EXTERNAL_URL=https://your-service.onrender.com
```

### Custom Domain

1. In Render dashboard, go to service settings
2. Click "Custom Domains"
3. Add your domain and configure DNS
4. Render automatically provisions SSL certificates

## 🔐 Security Best Practices

### Authentication Token

- Always use a strong, randomly generated token
- Use Render's "Generate Value" feature for automatic generation
- Rotate tokens periodically

### CORS Configuration

For production, restrict CORS origins:

```bash
CORS_ORIGIN=https://your-domain.com,https://app.your-domain.com
```

### Network Security

- Render provides DDoS protection automatically
- Services run in isolated containers
- HTTPS is enforced by default

## 🛠️ Troubleshooting

### Common Issues

**Service won't start:**
1. Check build logs in Render dashboard
2. Verify environment variables are set correctly
3. Ensure `AUTH_TOKEN` is configured

**Claude can't connect:**
1. Verify service URL is accessible: `curl https://your-service.onrender.com/health`
2. Check AUTH_TOKEN matches in both Render and Claude config
3. Ensure Claude Desktop configuration is valid JSON

**Slow performance:**
1. Check if service is sleeping (free tier)
2. Consider upgrading to paid plan for always-on service
3. Verify region selection for optimal latency

**Database issues:**
1. Ensure persistent disk is mounted at `/app/data`
2. Check disk space usage in Render dashboard
3. Verify database file permissions

### Debug Information

Enable debug logging by setting:

```bash
LOG_LEVEL=debug
```

Access logs through:
- Render dashboard logs tab
- Service endpoint: `https://your-service.onrender.com/logs` (if enabled)

### Getting Help

If you encounter issues:

1. Check the [main README](../README.md) for general troubleshooting
2. Review Render's [documentation](https://render.com/docs)
3. Open an issue on the [GitHub repository](https://github.com/adedara1/mcp-n8n/issues)

## 📚 Additional Resources

- [Render Documentation](https://render.com/docs)
- [n8n-MCP Main README](../README.md)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)
- [Claude Desktop Setup Guide](../docs/README_CLAUDE_SETUP.md)

---

**Need help?** Join our community discussions or open an issue on GitHub. We're here to help make your n8n-MCP deployment successful! 🚀