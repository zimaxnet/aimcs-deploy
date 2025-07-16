#!/bin/bash

# GitHub Secrets Setup Script for Orb Game
# This script sets up all required secrets for the AIMCS Orb Game deployment

set -e

echo "🔐 Setting up GitHub secrets for Orb Game deployment..."

# Check if GitHub CLI is installed and authenticated
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI is not installed. Please install it first:"
    echo "   https://cli.github.com/"
    exit 1
fi

# Check if logged in to GitHub
if ! gh auth status &> /dev/null; then
    echo "🔐 Please log in to GitHub first:"
    gh auth login
fi

# Get current repository
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
echo "📦 Repository: $REPO"

# Function to set secret
set_secret() {
    local secret_name=$1
    local secret_value=$2
    local description=$3
    
    echo "🔧 Setting $secret_name..."
    echo "$secret_value" | gh secret set "$secret_name" --repo "$REPO" --body -
    echo "✅ $secret_name set successfully"
}

# Function to prompt for secret value
prompt_secret() {
    local secret_name=$1
    local description=$2
    local default_value=$3
    
    echo ""
    echo "📝 $description"
    if [ -n "$default_value" ]; then
        echo "   Default: $default_value"
    fi
    read -p "   Enter value for $secret_name: " secret_value
    
    if [ -z "$secret_value" ] && [ -n "$default_value" ]; then
        secret_value="$default_value"
    fi
    
    if [ -n "$secret_value" ]; then
        set_secret "$secret_name" "$secret_value" "$description"
    else
        echo "⚠️  Skipping $secret_name"
    fi
}

echo ""
echo "🚀 Setting up Orb Game secrets..."
echo ""

# Azure OpenAI Secrets
echo "🔵 Azure OpenAI Configuration"
echo "=============================="

prompt_secret "AZURE_OPENAI_ENDPOINT" \
    "Azure OpenAI service endpoint" \
    "https://aimcs-foundry.cognitiveservices.azure.com/"

prompt_secret "AZURE_OPENAI_API_KEY" \
    "Azure OpenAI API key (get from Azure Portal)" \
    ""

prompt_secret "AZURE_OPENAI_DEPLOYMENT" \
    "Azure OpenAI chat model deployment name" \
    "o4-mini"

prompt_secret "AZURE_OPENAI_TTS_DEPLOYMENT" \
    "Azure OpenAI TTS model deployment name" \
    "gpt-4o-mini-tts"

# MongoDB Atlas Secret
echo ""
echo "🟢 MongoDB Atlas Configuration"
echo "=============================="

prompt_secret "MONGO_URI" \
    "MongoDB Atlas connection string (format: mongodb+srv://username:password@cluster.mongodb.net/aimcs?retryWrites=true&w=majority)" \
    ""

# Perplexity API Secret (Optional)
echo ""
echo "🟡 Perplexity API Configuration (Optional)"
echo "=========================================="

prompt_secret "PERPLEXITY_API_KEY" \
    "Perplexity API key for live news fetching (optional)" \
    ""

# Azure Deployment Secrets
echo ""
echo "🔴 Azure Deployment Configuration"
echo "================================="

prompt_secret "AZURE_STATIC_WEB_APPS_API_TOKEN_PROUD_HILL_01B4B180F" \
    "Azure Static Web Apps deployment token" \
    ""

# Optional: Azure Service Principal (for advanced deployments)
echo ""
echo "⚪ Azure Service Principal (Optional)"
echo "===================================="

read -p "   Do you want to set up Azure service principal credentials? (y/N): " setup_sp
if [[ $setup_sp =~ ^[Yy]$ ]]; then
    prompt_secret "AZURE_CREDENTIALS" \
        "Azure service principal JSON credentials" \
        ""
fi

echo ""
echo "✅ GitHub secrets setup completed!"
echo ""
echo "📋 Summary of secrets set:"
gh secret list --repo "$REPO"

echo ""
echo "🔗 You can view and manage secrets at:"
echo "   https://github.com/$REPO/settings/secrets/actions"
echo ""
echo "🚀 Ready to deploy the Orb Game!" 