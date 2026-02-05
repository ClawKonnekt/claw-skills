#!/bin/bash
#
# Firebase Deploy Helper - Multi-Site Support
# Usage: ./deploy-to-firebase.sh <site-name> <project-path> [public-dir]
#

set -e

SITE_NAME="${1:-default}"
PROJECT_PATH="${2:-.}"
PUBLIC_DIR="${3:-dist}"
CREDENTIALS_PATH="/home/node/.openclaw/workspace/.secrets/firebase-claw-e9e6f.json"

# Check credentials exist
if [ ! -f "$CREDENTIALS_PATH" ]; then
    echo "❌ Service account key not found at $CREDENTIALS_PATH"
    exit 1
fi

# Check project path exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Project path not found: $PROJECT_PATH"
    exit 1
fi

cd "$PROJECT_PATH"

# Create firebase.json with site target
echo "📝 Creating firebase.json for site: $SITE_NAME"
cat > firebase.json << EOF
{
  "hosting": {
    "site": "$SITE_NAME",
    "public": "$PUBLIC_DIR",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
EOF

# Check if public directory exists
if [ ! -d "$PUBLIC_DIR" ]; then
    echo "⚠️  Public directory '$PUBLIC_DIR' not found"
    echo "Available directories:"
    ls -la | grep "^d" | awk '{print $9}' | grep -v "^\.$\|^\.\.$" || true
    echo ""
    echo "Options:"
    echo "1. Build the project first (npm run build)"
    echo "2. Specify correct public dir: ./deploy-to-firebase.sh $SITE_NAME . public"
    exit 1
fi

# Export credentials
export GOOGLE_APPLICATION_CREDENTIALS="$CREDENTIALS_PATH"

# Check if site exists, create if not
echo "🔍 Checking if site '$SITE_NAME' exists..."
if ! npx firebase-tools hosting:sites:list --project claw-e9e6f 2>/dev/null | grep -q "$SITE_NAME"; then
    echo "📦 Creating new site: $SITE_NAME"
    npx firebase-tools hosting:sites:create "$SITE_NAME" --project claw-e9e6f || true
fi

echo "🚀 Deploying site '$SITE_NAME' to Firebase..."
echo "   Project: claw-e9e6f"
echo "   Site:    $SITE_NAME"
echo "   Public:  $PUBLIC_DIR"
echo ""

npx firebase-tools deploy --project claw-e9e6f --only "hosting:$SITE_NAME"

echo ""
if [ "$SITE_NAME" = "default" ]; then
    echo "✅ Deployed to: https://claw-e9e6f.web.app"
else
    echo "✅ Deployed to: https://${SITE_NAME}--claw-e9e6f.web.app"
fi
