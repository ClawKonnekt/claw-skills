---
name: firebase-deployer
description: Firebase Hosting deployment automation for agents. Use when deploying static websites, web apps, or any HTML/CSS/JS projects to Firebase Hosting. Provides the claw-e9e6f project configuration and deployment workflows.
---

# Firebase Deployer

Firebase Hosting deployment automation using the dedicated `claw-e9e6f` project.

## Overview

This skill provides agents with full access to deploy any static website to Firebase Hosting via the pre-configured `claw-e9e6f` project.

**Project:** `claw-e9e6f`  
**Service Account:** `claw-deployer@claw-e9e6f.iam.gserviceaccount.com`  
**Default Domain:** `https://claw-e9e6f.web.app`  
**Multi-Site Support:** ✅ Yes - deploy unlimited sites to one project  
**Custom Domain Support:** Yes

## Multi-Site Deployment

Firebase Hosting supports multiple sites in one project. Each site gets its own URL:

| Site Name | URL |
|-----------|-----|
| `default` | `https://claw-e9e6f.web.app` |
| `agentflow` | `https://agentflow--claw-e9e6f.web.app` |
| `scrapenow` | `https://scrapenow--claw-e9e6f.web.app` |
| `portfolio` | `https://portfolio--claw-e9e6f.web.app` |

## Prerequisites

Before deploying, ensure:
1. Service account key exists at: `.secrets/firebase-claw-e9e6f.json`
2. Firebase CLI is available (via `npx firebase-tools`)
3. Project has a build directory (e.g., `dist/`, `build/`, or `public/`)

## Quick Deploy

### Standard Static Site

```bash
# Set credentials
export GOOGLE_APPLICATION_CREDENTIALS=".secrets/firebase-claw-e9e6f.json"

# Navigate to project
cd /path/to/website

# Create firebase.json if it doesn't exist
if [ ! -f firebase.json ]; then
cat > firebase.json << 'EOF'
{
  "hosting": {
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
  }
}
EOF
fi

# Deploy
npx firebase-tools deploy --project claw-e9e6f --only hosting
```

### React/Vue/Angular App

```bash
export GOOGLE_APPLICATION_CREDENTIALS=".secrets/firebase-claw-e9e6f.json"
cd /path/to/app

# Build first
npm run build

# Deploy
cat > firebase.json << 'EOF'
{
  "hosting": {
    "public": "dist",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{"source": "**", "destination": "/index.html"}]
  }
}
EOF

npx firebase-tools deploy --project claw-e9e6f --only hosting
```

### Simple HTML Site

```bash
export GOOGLE_APPLICATION_CREDENTIALS=".secrets/firebase-claw-e9e6f.json"
cd /path/to/html-site

# Use current directory as public folder
cat > firebase.json << 'EOF'
{
  "hosting": {
    "public": ".",
    "ignore": ["firebase.json", "**/.*"]
  }
}
EOF

npx firebase-tools deploy --project claw-e9e6f --only hosting
```

## Multi-Site Deployment (Multiple Websites)

Deploy multiple websites to the same Firebase project using separate sites.

### 1. Create a New Site

```bash
export GOOGLE_APPLICATION_CREDENTIALS=".secrets/firebase-claw-e9e6f.json"

# Create a new site (e.g., "agentflow")
npx firebase-tools hosting:sites:create agentflow --project claw-e9e6f

# Output: Site created at https://agentflow--claw-e9e6f.web.app
```

### 2. Deploy to Specific Site

```bash
export GOOGLE_APPLICATION_CREDENTIALS=".secrets/firebase-claw-e9e6f.json"
cd /path/to/website

# Create firebase.json with target
cat > firebase.json << 'EOF'
{
  "hosting": {
    "site": "agentflow",
    "public": "dist",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{"source": "**", "destination": "/index.html"}]
  }
}
EOF

# Deploy to the specific site
npx firebase-tools deploy --project claw-e9e6f --only hosting:agentflow
```

### 3. List All Sites

```bash
export GOOGLE_APPLICATION_CREDENTIALS=".secrets/firebase-claw-e9e6f.json"
npx firebase-tools hosting:sites:list --project claw-e9e6f
```

### 4. Deploy Multiple Sites (Monorepo)

For a project with multiple sites:

```json
{
  "hosting": [
    {
      "site": "main",
      "public": "apps/main/dist",
      "ignore": ["firebase.json", "**/.*"]
    },
    {
      "site": "admin",
      "public": "apps/admin/dist",
      "ignore": ["firebase.json", "**/.*"]
    },
    {
      "site": "docs",
      "public": "apps/docs/dist",
      "ignore": ["firebase.json", "**/.*"]
    }
  ]
}
```

Deploy all:
```bash
npx firebase-tools deploy --project claw-e9e6f --only hosting
```

Deploy specific site:
```bash
npx firebase-tools deploy --project claw-e9e6f --only hosting:admin
```

## Deployment Workflows

### 1. Deploy from GitHub Repo

```typescript
// Clone, build, and deploy
exec({
  command: `
    export GOOGLE_APPLICATION_CREDENTIALS=".secrets/firebase-claw-e9e6f.json" &&
    cd /tmp &&
    git clone https://github.com/user/repo.git deploy-temp &&
    cd deploy-temp &&
    npm install &&
    npm run build &&
    echo '{"hosting":{"public":"dist","ignore":["firebase.json","**/.*"]}}' > firebase.json &&
    npx firebase-tools deploy --project claw-e9e6f --only hosting
  `,
  timeout: 300
})
```

### 2. Deploy Local Project

```typescript
// Deploy current workspace project
const projectPath = "/home/node/.openclaw/workspace/my-website";

// Check for build directory
const buildDirs = ["dist", "build", "public", "out"];

// Create firebase.json
write({
  path: `${projectPath}/firebase.json`,
  content: JSON.stringify({
    hosting: {
      public: "dist",
      ignore: ["firebase.json", "**/.*", "**/node_modules/**"],
      rewrites: [{ source: "**", destination: "/index.html" }]
    }
  }, null, 2)
});

// Deploy
exec({
  command: `cd ${projectPath} && export GOOGLE_APPLICATION_CREDENTIALS="/home/node/.openclaw/workspace/.secrets/firebase-claw-e9e6f.json" && npx firebase-tools deploy --project claw-e9e6f --only hosting`,
  timeout: 120
});
```

### 3. Deploy with Custom Domain

```bash
export GOOGLE_APPLICATION_CREDENTIALS=".secrets/firebase-claw-e9e6f.json"

# First deploy the site
npx firebase-tools deploy --project claw-e9e6f --only hosting

# Then add custom domain
npx firebase-tools hosting:channel:deploy production --project claw-e9e6f
```

## Available Firebase Services

With the service account key, agents have full access to:

| Service | Access | Use Cases |
|---------|--------|-----------|
| **Firebase Hosting** | Full | Deploy static sites, SPAs, PWAs |
| **Firestore** | Full | NoSQL database, collections, documents |
| **Firebase Auth** | Full | User auth, custom tokens, user management |
| **Firebase Rules** | Full | Security rules for Firestore & Storage |
| **Cloud Functions** | Full | Serverless backend functions |
| **Firebase Storage** | Full | File uploads, media storage |
| **Firebase Analytics** | Full | App analytics events |
| **Cloud Messaging** | Full | Push notifications |
| **Firebase Remote Config** | Full | Feature flags, app configuration |

---

## Firebase Hosting (Already Covered Above)

See Multi-Site Deployment section for hosting documentation.

---

## Firestore Database

### Create/Manage Collections

```bash
export GOOGLE_APPLICATION_CREDENTIALS=".secrets/firebase-claw-e9e6f.json"

# Create a new collection with document
cat > firestore-setup.json << 'EOF'
{
  "users": {
    "user1": {
      "name": "John Doe",
      "email": "john@example.com",
      "createdAt": "2026-02-05T00:00:00Z"
    }
  }
}
EOF
```

### Deploy Firestore Rules

```bash
cat > firestore.rules << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write for authenticated users
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public read-only collection
    match /public/{docId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
EOF

# Deploy rules
npx firebase-tools deploy --project claw-e9e6f --only firestore:rules
```

### Deploy Firestore Indexes

```bash
cat > firestore.indexes.json << 'EOF'
{
  "indexes": [
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
EOF

npx firebase-tools deploy --project claw-e9e6f --only firestore:indexes
```

### Quick Firestore Operations (Python)

```python
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize
cred = credentials.Certificate('.secrets/firebase-claw-e9e6f.json')
firebase_admin.initialize_app(cred, {'projectId': 'claw-e9e6f'})
db = firestore.client()

# Add document
db.collection('users').document('user1').set({
    'name': 'John Doe',
    'email': 'john@example.com'
})

# Read documents
users = db.collection('users').stream()
for user in users:
    print(f'{user.id} => {user.to_dict()}')
```

---

## Firebase Authentication

### Deploy Auth Configuration

```bash
cat > auth-config.json << 'EOF'
{
  "signInOptions": [
    "google.com",
    "password",
    "anonymous"
  ],
  "callbacks": {
    "signInSuccessWithAuthResult": null
  }
}
EOF
```

### Create Custom Token (Python)

```python
import firebase_admin
from firebase_admin import credentials, auth

cred = credentials.Certificate('.secrets/firebase-claw-e9e6f.json')
firebase_admin.initialize_app(cred)

# Create custom token for user
custom_token = auth.create_custom_token('user_id', {'admin': True})
print(custom_token)
```

### Manage Users (Python)

```python
from firebase_admin import auth

# Create user
user = auth.create_user(
    email='user@example.com',
    password='secretPassword',
    display_name='John Doe'
)
print(f'Created user: {user.uid}')

# Get user by email
user = auth.get_user_by_email('user@example.com')

# List all users
page = auth.list_users()
for user in page.users:
    print(f'User: {user.uid} - {user.email}')

# Delete user
auth.delete_user('user_id')
```

---

## Cloud Functions

### Initialize Functions

```bash
export GOOGLE_APPLICATION_CREDENTIALS=".secrets/firebase-claw-e9e6f.json"

# Initialize functions in project
npx firebase-tools init functions --project claw-e9e6f
```

### Deploy Functions

```bash
# Deploy all functions
npx firebase-tools deploy --project claw-e9e6f --only functions

# Deploy specific function
npx firebase-tools deploy --project claw-e9e6f --only functions:myFunction

# Deploy with region
npx firebase-tools deploy --project claw-e9e6f --only functions --region us-central1
```

### Example Function (index.js)

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// HTTP Function
exports.helloWorld = functions.https.onRequest((req, res) => {
  res.json({message: 'Hello from claw-e9e6f!'});
});

// Firestore Trigger
exports.onUserCreate = functions.firestore
  .document('users/{userId}')
  .onCreate((snap, context) => {
    const user = snap.data();
    console.log(`New user created: ${context.params.userId}`);
    return snap.ref.update({createdAt: admin.firestore.FieldValue.serverTimestamp()});
  });

// Scheduled Function (requires Blaze plan)
exports.scheduledJob = functions.pubsub.schedule('every 24 hours')
  .onRun(async (context) => {
    console.log('Running daily job');
    return null;
  });
```

---

## Firebase Storage

### Deploy Storage Rules

```bash
cat > storage.rules << 'EOF'
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to read/write their own files
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public read-only folder
    match /public/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
EOF

npx firebase-tools deploy --project claw-e9e6f --only storage
```

### Storage Operations (Python)

```python
from firebase_admin import storage

# Upload file
bucket = storage.bucket()
blob = bucket.blob('uploads/file.txt')
blob.upload_from_filename('local-file.txt')
print(f'Uploaded to {blob.public_url}')

# Download file
blob = bucket.blob('uploads/file.txt')
blob.download_to_filename('downloaded-file.txt')

# List files
blobs = bucket.list_blobs(prefix='uploads/')
for blob in blobs:
    print(blob.name)
```

---

## Complete Firebase Setup (One Command)

Deploy everything at once:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=".secrets/firebase-claw-e9e6f.json"

# Deploy all Firebase services
npx firebase-tools deploy --project claw-e9e6f

# Or deploy specific services
npx firebase-tools deploy --project claw-e9e6f --only hosting,firestore,functions,storage
```

---

## Configuration Templates

### Single-Page App (React/Vue/Angular)

```json
{
  "hosting": {
    "public": "dist",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{"source": "**", "destination": "/index.html"}],
    "headers": [
      {
        "source": "/*.js",
        "headers": [{"key": "Cache-Control", "value": "max-age=31536000"}]
      }
    ]
  }
}
```

### Static Site with Clean URLs

```json
{
  "hosting": {
    "public": "public",
    "cleanUrls": true,
    "trailingSlash": false,
    "ignore": ["firebase.json", "**/.*"]
  }
}
```

### Multi-site Setup

```json
{
  "hosting": [
    {
      "target": "app",
      "public": "app-dist",
      "ignore": ["firebase.json", "**/.*"]
    },
    {
      "target": "admin",
      "public": "admin-dist",
      "ignore": ["firebase.json", "**/.*"]
    }
  ]
}
```

## CLI Commands Reference

### Standard Commands
```bash
# Set credentials (required for all commands)
export GOOGLE_APPLICATION_CREDENTIALS=".secrets/firebase-claw-e9e6f.json"

# Deploy hosting (default site)
npx firebase-tools deploy --project claw-e9e6f --only hosting

# Deploy to preview channel
npx firebase-tools hosting:channel:deploy my-feature --project claw-e9e6f

# List deployments
npx firebase-tools hosting:channel:list --project claw-e9e6f

# Rollback
npx firebase-tools hosting:clone claw-e9e6f:live claw-e9e6f:live --project claw-e9e6f

# Get deployment URL
npx firebase-tools hosting:channel:open live --project claw-e9e6f
```

### Firestore Commands
```bash
# Deploy Firestore rules
npx firebase-tools deploy --project claw-e9e6f --only firestore:rules

# Deploy Firestore indexes
npx firebase-tools deploy --project claw-e9e6f --only firestore:indexes

# Get Firestore rules
npx firebase-tools firestore:rules:get --project claw-e9e6f
```

### Cloud Functions Commands
```bash
# Deploy all functions
npx firebase-tools deploy --project claw-e9e6f --only functions

# Deploy specific function
npx firebase-tools deploy --project claw-e9e6f --only functions:myFunction

# List functions
npx firebase-tools functions:list --project claw-e9e6f

# Delete function
npx firebase-tools functions:delete myFunction --project claw-e9e6f

# View function logs
npx firebase-tools functions:log --project claw-e9e6f
```

### Storage Commands
```bash
# Deploy storage rules
npx firebase-tools deploy --project claw-e9e6f --only storage

# Get storage rules
npx firebase-tools storage:rules:get --project claw-e9e6f
```

### Complete Deployment
```bash
# Deploy EVERYTHING (hosting + database + auth + functions + storage)
npx firebase-tools deploy --project claw-e9e6f

# Deploy specific combination
npx firebase-tools deploy --project claw-e9e6f --only hosting,firestore,functions
```

---

## Complete Project Setup Example

Set up a full-stack app with everything:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=".secrets/firebase-claw-e9e6f.json"

# 1. Create site for the app
npx firebase-tools hosting:sites:create myapp --project claw-e9e6f

# 2. Create firebase.json with all services
cat > firebase.json << 'EOF'
{
  "hosting": {
    "site": "myapp",
    "public": "dist",
    "ignore": ["firebase.json", "**/.*"]
  },
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "functions": [
    {
      "source": "functions",
      "codebase": "default"
    }
  ],
  "storage": {
    "rules": "storage.rules"
  }
}
EOF

# 3. Create Firestore rules
cat > firestore.rules << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
EOF

# 4. Create Storage rules
cat > storage.rules << 'EOF'
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
EOF

# 5. Deploy everything
npx firebase-tools deploy --project claw-e9e6f

# Result: Full-stack app deployed with auth, database, storage, and hosting!
```

## GitHub Actions Integration

For CI/CD pipelines:

```yaml
name: Deploy to Firebase
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npm run build
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT_CLAW_E9E6F }}'
          channelId: live
          projectId: claw-e9e6f
```

## Troubleshooting

### "Failed to authenticate"
```bash
# Verify service account file exists
ls -la .secrets/firebase-claw-e9e6f.json

# Check it's valid JSON
cat .secrets/firebase-claw-e9e6f.json | head -5
```

### "No public directory specified"
```bash
# Create firebase.json with correct public path
echo '{"hosting":{"public":"dist"}}' > firebase.json
```

### "Build directory not found"
```bash
# Check what build directories exist
ls -la | grep -E "dist|build|public|out"

# Update firebase.json accordingly
```

## Best Practices

1. **Always set GOOGLE_APPLICATION_CREDENTIALS** before running firebase commands
2. **Use .firebase.json** to configure hosting behavior per-project
3. **Test locally first** with `npx firebase-tools emulators:start`
4. **Use preview channels** for testing before deploying to live
5. **Clean builds** - run `npm run build` fresh before each deploy
6. **Check .gitignore** - don't commit firebase.json or build dirs

## Security Notes

- Service account key is stored in `.secrets/` (gitignored)
- Key has Firebase Admin role - full project access
- Never share the service account JSON
- Rotate keys periodically if needed

## Project Details

```
Project ID: claw-e9e6f
Service Account: claw-deployer@claw-e9e6f.iam.gserviceaccount.com
Default URL: https://claw-e9e6f.web.app
Location: us-central (default)
```

## When to Use This Skill

- ✅ Deploying static websites to Firebase Hosting (single or multi-site)
- ✅ Setting up Firestore databases and security rules
- ✅ Configuring Firebase Authentication
- ✅ Deploying Cloud Functions
- ✅ Setting up Firebase Storage with rules
- ✅ Full-stack app deployment (Hosting + DB + Auth + Functions + Storage)
- ✅ CI/CD pipelines for Firebase projects
- ✅ Creating preview deployments for testing

## Examples

**Deploy AgentFlow landing page:**
```bash
cd ventures/agentflow-automation/landing-page
export GOOGLE_APPLICATION_CREDENTIALS="../../../.secrets/firebase-claw-e9e6f.json"
echo '{"hosting":{"public":"."}}' > firebase.json
npx firebase-tools deploy --project claw-e9e6f --only hosting
```

**Deploy Formula Forge:**
```bash
cd formula-forge
export GOOGLE_APPLICATION_CREDENTIALS="../.secrets/firebase-claw-e9e6f.json"
npm run build
echo '{"hosting":{"public":"dist","rewrites":[{"source":"**","destination":"/index.html"}]}}' > firebase.json
npx firebase-tools deploy --project claw-e9e6f --only hosting
```

**Multi-Site: Deploy multiple websites**

```bash
# Deploy AgentFlow to its own site
export GOOGLE_APPLICATION_CREDENTIALS=".secrets/firebase-claw-e9e6f.json"

# Create and deploy agentflow site
cd ventures/agentflow-automation/landing-page
echo '{"hosting":{"site":"agentflow","public":"."}}' > firebase.json
npx firebase-tools deploy --project claw-e9e6f --only hosting:agentflow
# Result: https://agentflow--claw-e9e6f.web.app

# Deploy ScrapeNow to its own site
cd ../scrapenow/landing-page
echo '{"hosting":{"site":"scrapenow","public":"."}}' > firebase.json
npx firebase-tools deploy --project claw-e9e6f --only hosting:scrapenow
# Result: https://scrapenow--claw-e9e6f.web.app

# Deploy personal portfolio
cd ~/projects/portfolio
echo '{"hosting":{"site":"portfolio","public":"dist"}}' > firebase.json
npx firebase-tools deploy --project claw-e9e6f --only hosting:portfolio
# Result: https://portfolio--claw-e9e6f.web.app
```

**Using the helper script for multi-site:**
```bash
# Usage: ./deploy-to-firebase.sh <site-name> <project-path> [public-dir]

./skills/firebase-deployer/deploy-to-firebase.sh agentflow ventures/agentflow-automation/landing-page .
./skills/firebase-deployer/deploy-to-firebase.sh scrapenow ventures/scrapenow/landing-page .
./skills/firebase-deployer/deploy-to-firebase.sh portfolio ~/projects/portfolio dist
```
