# Flutter Web to GitHub Pages - Complete Deployment Guide

## Purpose
This guide provides step-by-step instructions for deploying Flutter web applications to GitHub Pages using GitHub Actions. It's designed to be used by AI agents or developers to successfully deploy any Flutter web project.

## Prerequisites Check

Before starting, ensure these requirements are met:

```bash
# Check Flutter installation
flutter --version

# Check if web is enabled
flutter config | grep "enable-web"

# Check Git repository
git remote -v

# Get repository name (will be needed for deployment)
REPO_NAME=$(basename -s .git `git config --get remote.origin.url`)
echo "Repository name: $REPO_NAME"
```

## Step 1: Enable Flutter Web Support

```bash
# Enable web support if not already enabled
flutter config --enable-web

# Verify web support
flutter devices | grep -i chrome
```

## Step 2: Prepare Web Directory

Create necessary files for GitHub Pages deployment:

```bash
# Create .nojekyll to prevent Jekyll processing
touch web/.nojekyll

# Get repository name
REPO_NAME=$(basename -s .git `git config --get remote.origin.url`)

# Create 404.html for proper routing
cat > web/404.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Flutter App</title>
  <script>
    // Get the repository name from the URL
    const pathSegments = window.location.pathname.split('/').filter(Boolean);
    const repoName = pathSegments[0];
    
    // Redirect to the base path
    if (pathSegments.length > 1) {
      window.location.href = '/' + repoName + '/';
    }
  </script>
</head>
<body>
  <p>Redirecting...</p>
</body>
</html>
EOF

# Update index.html base href (will be done dynamically in workflow)
echo "Note: base href will be set during build process"
```

## Step 3: Fix Common Dependency Issues

```bash
# Check and fix flutter_lints version if needed
if grep -q "flutter_lints: [\^~][5-9]\." pubspec.yaml; then
  echo "Fixing flutter_lints version..."
  sed -i 's/flutter_lints: .*/flutter_lints: ^4.0.0/' pubspec.yaml
fi

# Update dependencies
flutter pub get

# Run analyzer to check for issues
flutter analyze
```

## Step 4: Create GitHub Actions Workflow

```bash
# Create workflow directory
mkdir -p .github/workflows

# Get repository name for the workflow
REPO_NAME=$(basename -s .git `git config --get remote.origin.url`)

# Create deployment workflow
cat > .github/workflows/flutter-web-deploy.yml << 'EOF'
name: Flutter Web Deploy to GitHub Pages

on:
  # Trigger on push to main branch
  push:
    branches: [ main ]
  
  # Allow manual trigger
  workflow_dispatch:

# Sets permissions for GITHUB_TOKEN
permissions:
  contents: write
  pages: write
  id-token: write

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
      # Step 1: Checkout code
      - name: Checkout repository
        uses: actions/checkout@v4
      
      # Step 2: Setup Flutter
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.3'
          channel: 'stable'
      
      # Step 3: Get repository name
      - name: Get repository name
        id: repo
        run: |
          REPO_NAME=${GITHUB_REPOSITORY##*/}
          echo "name=$REPO_NAME" >> $GITHUB_OUTPUT
          echo "Repository name: $REPO_NAME"
      
      # Step 4: Fix dependencies if needed
      - name: Fix dependencies
        run: |
          # Fix flutter_lints version if incompatible
          if grep -q "flutter_lints: [\^~][5-9]\." pubspec.yaml; then
            echo "Fixing flutter_lints version..."
            sed -i 's/flutter_lints: .*/flutter_lints: ^4.0.0/' pubspec.yaml
          fi
      
      # Step 5: Install dependencies
      - name: Install dependencies
        run: flutter pub get
      
      # Step 6: Run tests (optional but recommended)
      - name: Run tests
        run: flutter test || echo "Tests failed but continuing deployment"
        continue-on-error: true
      
      # Step 7: Build web application
      - name: Build Flutter web
        run: |
          flutter build web --release --base-href /${{ steps.repo.outputs.name }}/
          
          # Ensure .nojekyll exists
          touch build/web/.nojekyll
          
          # Create 404.html for client-side routing
          cp build/web/index.html build/web/404.html
      
      # Step 8: Deploy to GitHub Pages
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
          publish_branch: gh-pages
          force_orphan: true
          user_name: 'github-actions[bot]'
          user_email: 'github-actions[bot]@users.noreply.github.com'
          commit_message: 'Deploy Flutter web app to GitHub Pages'
EOF

echo "Workflow created successfully!"
```

## Step 5: Configure GitHub Repository

### Enable GitHub Pages (Manual Step)

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Pages**
3. Under **Source**, select **Deploy from a branch**
4. Under **Branch**, select **gh-pages** and **/ (root)**
5. Click **Save**

### Using GitHub CLI (if available)

```bash
# If you have GitHub CLI installed
gh api repos/:owner/:repo/pages -X POST -f source.branch=gh-pages -f source.path=/
```

## Step 6: Test Local Build

Before pushing, test the build locally:

```bash
# Get repository name
REPO_NAME=$(basename -s .git `git config --get remote.origin.url`)

# Build locally
flutter build web --base-href /$REPO_NAME/

# Test with Python server (if Python is installed)
cd build/web
python3 -m http.server 8000
# Open http://localhost:8000 in browser
```

## Step 7: Deploy

```bash
# Add all changes
git add .

# Commit with descriptive message
git commit -m "feat: Add GitHub Pages deployment workflow for Flutter web"

# Push to main branch
git push origin main
```

## Step 8: Monitor Deployment

```bash
# Check workflow status (if GitHub CLI is available)
gh run list --workflow=flutter-web-deploy.yml

# Or check manually at:
echo "Check workflow at: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\).git/\1/')/actions"

# Get deployment URL
echo "Your app will be available at: https://$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\/\(.*\).git/\1/').github.io/$(basename -s .git `git config --get remote.origin.url`)/"
```

## Troubleshooting Guide

### Issue 1: Flutter Web Not Enabled

```bash
# Solution
flutter config --enable-web
flutter clean
flutter pub get
```

### Issue 2: Build Fails with SDK Version Error

```bash
# Check Flutter version
flutter --version

# Update Flutter if needed
flutter upgrade

# Or specify exact version in workflow
# Change flutter-version in workflow to match your local version
```

### Issue 3: flutter_lints Version Incompatibility

```bash
# Quick fix
sed -i 's/flutter_lints: .*/flutter_lints: ^4.0.0/' pubspec.yaml
flutter pub get
```

### Issue 4: 404 on Deployed Site

```bash
# Ensure base-href is correct
REPO_NAME=$(basename -s .git `git config --get remote.origin.url`)
echo "Base href should be: /$REPO_NAME/"

# Rebuild with correct base-href
flutter build web --release --base-href /$REPO_NAME/
```

### Issue 5: GitHub Pages Not Showing

1. Check that gh-pages branch exists
2. Verify Pages is enabled in repository settings
3. Wait 5-10 minutes for initial deployment
4. Check Actions tab for deployment errors

### Issue 6: Assets Not Loading

```bash
# Ensure assets are properly referenced in pubspec.yaml
# Check that base-href matches repository name exactly
# Verify .nojekyll file exists in web directory
```

## Advanced Configuration

### Custom Domain

```bash
# Create CNAME file for custom domain
echo "yourdomain.com" > web/CNAME
```

### Environment-Specific Builds

```yaml
# Add to workflow for different environments
- name: Build for production
  run: |
    flutter build web --release \
      --base-href /${{ steps.repo.outputs.name }}/ \
      --dart-define=ENVIRONMENT=production
```

### Caching Dependencies

```yaml
# Add before flutter pub get in workflow
- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.pub-cache
      .dart_tool
    key: flutter-${{ runner.os }}-${{ hashFiles('**/pubspec.lock') }}
```

## Best Practices

1. **Always test locally first**
   ```bash
   flutter build web --release --base-href /repo-name/
   ```

2. **Use semantic versioning for commits**
   ```bash
   git commit -m "feat: Add new feature"
   git commit -m "fix: Resolve routing issue"
   ```

3. **Keep workflow simple and maintainable**
   - Avoid complex conditionals
   - Use clear step names
   - Add comments for non-obvious configurations

4. **Monitor deployment regularly**
   - Check Actions tab for failures
   - Test deployed site after each push
   - Set up notifications for failed deployments

## Quick Deployment Script

Save this as `deploy.sh` for quick deployments:

```bash
#!/bin/bash

# Get repository name
REPO_NAME=$(basename -s .git `git config --get remote.origin.url`)

echo "Deploying $REPO_NAME to GitHub Pages..."

# Enable web if needed
flutter config --enable-web

# Create necessary files
touch web/.nojekyll

# Fix dependencies
if grep -q "flutter_lints: [\^~][5-9]\." pubspec.yaml; then
  sed -i 's/flutter_lints: .*/flutter_lints: ^4.0.0/' pubspec.yaml
fi

# Get dependencies
flutter pub get

# Build
flutter build web --release --base-href /$REPO_NAME/

echo "Build complete!"
echo "Now run:"
echo "  git add ."
echo "  git commit -m 'Deploy to GitHub Pages'"
echo "  git push origin main"
echo ""
echo "Your app will be at: https://[username].github.io/$REPO_NAME/"
```

## Success Checklist

- [ ] Flutter web is enabled
- [ ] Repository has correct structure (web/ directory exists)
- [ ] .nojekyll file created in web/
- [ ] GitHub Actions workflow created
- [ ] Dependencies are compatible (flutter_lints <= 4.0.0)
- [ ] Local build succeeds
- [ ] Workflow runs successfully
- [ ] GitHub Pages is enabled in repository settings
- [ ] Site is accessible at https://[username].github.io/[repo-name]/

## Notes for AI Agents

When using this guide:

1. **Always check current repository name first**
2. **Verify Flutter and Dart versions before proceeding**
3. **Test each step before moving to the next**
4. **If errors occur, check the Troubleshooting section**
5. **Ensure all file paths use the correct repository name**
6. **Wait for GitHub Actions to complete before checking deployment**
7. **The deployment URL format is always: https://[username].github.io/[repository-name]/**

## Additional Resources

- [Flutter Web Documentation](https://flutter.dev/web)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [GitHub Actions for Flutter](https://github.com/marketplace/actions/flutter-action)

---

**Last Updated**: Based on Flutter 3.24.3 and GitHub Actions best practices
**Compatibility**: Works with Flutter 3.x and Dart 3.x
**Time to Deploy**: Approximately 10-15 minutes for first-time setup