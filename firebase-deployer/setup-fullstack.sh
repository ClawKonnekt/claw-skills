#!/bin/bash
#
# Firebase Full-Stack Setup Helper
# Creates a complete Firebase project with Hosting + Firestore + Auth + Storage
#
# Usage: ./setup-fullstack.sh <site-name> [project-path]
#

set -e

SITE_NAME="${1:-myapp}"
PROJECT_PATH="${2:-.}"
CREDENTIALS_PATH="/home/node/.openclaw/workspace/.secrets/firebase-claw-e9e6f.json"

echo "🚀 Firebase Full-Stack Setup for: $SITE_NAME"
echo ""

# Check credentials
if [ ! -f "$CREDENTIALS_PATH" ]; then
    echo "❌ Service account key not found at $CREDENTIALS_PATH"
    exit 1
fi

export GOOGLE_APPLICATION_CREDENTIALS="$CREDENTIALS_PATH"

# Create project directory
mkdir -p "$PROJECT_PATH"
cd "$PROJECT_PATH"

echo "📦 Creating Firebase configuration files..."

# Create firebase.json
cat > firebase.json << EOF
{
  "hosting": {
    "site": "$SITE_NAME",
    "public": "dist",
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
  },
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  }
}
EOF

# Create Firestore rules
cat > firestore.rules << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public data - anyone can read, authenticated can write
    match /public/{docId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Default deny
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
EOF

# Create Firestore indexes
cat > firestore.indexes.json << 'EOF'
{
  "indexes": [],
  "fieldOverrides": []
}
EOF

# Create Storage rules
cat > storage.rules << 'EOF'
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User files
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public files
    match /public/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Default deny
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
EOF

echo "✅ Configuration files created:"
echo "   - firebase.json"
echo "   - firestore.rules"
echo "   - firestore.indexes.json"
echo "   - storage.rules"
echo ""

# Check if site exists, create if not
echo "🔍 Checking if site '$SITE_NAME' exists..."
if ! npx firebase-tools hosting:sites:list --project claw-e9e6f 2>/dev/null | grep -q "$SITE_NAME"; then
    echo "📦 Creating new hosting site: $SITE_NAME"
    npx firebase-tools hosting:sites:create "$SITE_NAME" --project claw-e9e6f || true
    echo ""
fi

echo "🚀 Deploying Firebase configuration..."
npx firebase-tools deploy --project claw-e9e6f --only firestore:rules,firestore:indexes,storage

echo ""
echo "✅ Full-stack Firebase setup complete!"
echo ""
echo "🌐 Hosting URL: https://${SITE_NAME}--claw-e9e6f.web.app"
echo "📁 Project: $PROJECT_PATH"
echo ""
echo "Next steps:"
echo "1. Build your app to the 'dist' folder"
echo "2. Deploy hosting: npx firebase-tools deploy --project claw-e9e6f --only hosting:$SITE_NAME"
echo "3. Add Firebase Auth to your app"
echo "4. Use Firestore for your database"
