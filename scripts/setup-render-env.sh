#!/bin/bash

# n8n-MCP Render Environment Setup Script
# This script helps set up environment variables for testing Render deployment locally

set -e

echo "🚀 n8n-MCP Render Environment Setup"
echo "===================================="

# Check if .env.render.example exists
if [ ! -f ".env.render.example" ]; then
    echo "❌ Error: .env.render.example file not found!"
    echo "   Please run this script from the project root directory."
    exit 1
fi

# Create .env.render from template
echo "📋 Creating .env.render from template..."
cp .env.render.example .env.render

# Generate secure AUTH_TOKEN if openssl is available
if command -v openssl >/dev/null 2>&1; then
    echo "🔐 Generating secure AUTH_TOKEN..."
    AUTH_TOKEN=$(openssl rand -base64 32)
    
    # Replace the placeholder token in .env.render
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/your-secure-generated-token-here/${AUTH_TOKEN}/" .env.render
    else
        # Linux
        sed -i "s/your-secure-generated-token-here/${AUTH_TOKEN}/" .env.render
    fi
    
    echo "✅ Generated AUTH_TOKEN: ${AUTH_TOKEN}"
else
    echo "⚠️  openssl not found. Please manually set AUTH_TOKEN in .env.render"
fi

# Prompt for optional n8n configuration
echo ""
read -p "🤔 Do you want to configure n8n API integration? (y/N): " configure_n8n

if [[ $configure_n8n =~ ^[Yy]$ ]]; then
    echo ""
    echo "📝 n8n API Configuration:"
    read -p "   Enter your n8n API URL (e.g., https://your-n8n.example.com): " n8n_url
    read -p "   Enter your n8n API Key: " n8n_key
    
    if [ ! -z "$n8n_url" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|# N8N_API_URL=|N8N_API_URL=${n8n_url}|" .env.render
        else
            sed -i "s|# N8N_API_URL=|N8N_API_URL=${n8n_url}|" .env.render
        fi
        echo "✅ Set N8N_API_URL: ${n8n_url}"
    fi
    
    if [ ! -z "$n8n_key" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|# N8N_API_KEY=|N8N_API_KEY=${n8n_key}|" .env.render
        else
            sed -i "s|# N8N_API_KEY=|N8N_API_KEY=${n8n_key}|" .env.render
        fi
        echo "✅ Set N8N_API_KEY: ${n8n_key:0:10}..."
    fi
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📁 Configuration file created: .env.render"
echo ""
echo "🚀 Next steps:"
echo "   1. Review and customize .env.render if needed"
echo "   2. Test locally: npm run build && npm run start:http"
echo "   3. Deploy to Render using the Deploy button"
echo "   4. Copy environment variables from .env.render to Render dashboard"
echo ""
echo "🔗 Deployment guide: docs/RENDER_DEPLOYMENT.md"
echo ""

# Show the generated auth token for easy copying
if [ ! -z "$AUTH_TOKEN" ]; then
    echo "🔐 Your AUTH_TOKEN (copy this to Render):"
    echo "   ${AUTH_TOKEN}"
    echo ""
fi

echo "✨ Happy deploying!"