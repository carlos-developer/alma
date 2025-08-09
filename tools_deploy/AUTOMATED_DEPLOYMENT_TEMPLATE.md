# AUTOMATED DEPLOYMENT TEMPLATE - Flutter to GitHub Pages

## Objetivo
Esta guía proporciona un proceso automatizado y libre de errores para desplegar aplicaciones Flutter en GitHub Pages. Está diseñada para ser ejecutada por desarrolladores o agentes automatizados sin intervención manual.

## Pre-requisitos Verificados

### 1. Requisitos del Sistema
```bash
# Verificar Flutter instalado y versión correcta
flutter --version
# Requerido: Flutter 3.32.0 o superior (incluye Dart 3.8.1+)

# Verificar Git instalado
git --version
# Requerido: Git 2.25 o superior

# Verificar GitHub CLI (opcional pero recomendado)
gh --version
```

### 2. Requisitos del Proyecto
```yaml
# pubspec.yaml debe tener:
environment:
  sdk: ^3.8.1  # Compatible con Flutter 3.32+
  
dev_dependencies:
  flutter_lints: ^4.0.0  # NO usar v5 hasta Flutter 3.35+
```

### 3. Requisitos de GitHub
- Repositorio con permisos de administrador
- GitHub Pages habilitado en el repositorio
- Token con permisos: `repo`, `workflow`, `pages`

## Secuencia de Pasos Sin Errores

### PASO 1: Preparación del Repositorio
```bash
# 1.1 Clonar repositorio (si es necesario)
git clone https://github.com/[USUARIO]/[REPOSITORIO].git
cd [REPOSITORIO]

# 1.2 Verificar rama principal
git branch
# Asegurarse de estar en main o master

# 1.3 Crear rama gh-pages (CRÍTICO - debe existir antes del deploy)
git checkout --orphan gh-pages
git rm -rf .
echo "<!DOCTYPE html><html><body><h1>Initializing GitHub Pages</h1></body></html>" > index.html
git add index.html
git commit -m "Initial gh-pages branch"
git push origin gh-pages

# 1.4 Volver a rama principal
git checkout main  # o master
```

### PASO 2: Configuración de GitHub Pages (Manual - Una vez)
1. Ir a: `https://github.com/[USUARIO]/[REPOSITORIO]/settings/pages`
2. En "Source": Seleccionar "Deploy from a branch"
3. En "Branch": Seleccionar `gh-pages`
4. En "Folder": Seleccionar `/ (root)`
5. Click en "Save"
6. Esperar confirmación: "Your site is ready to be published"

### PASO 3: Crear Estructura de Archivos

#### 3.1 Crear directorio para workflows
```bash
mkdir -p .github/workflows
```

#### 3.2 Crear archivo de workflow optimizado
**Archivo**: `.github/workflows/flutter-web-deploy.yml`

```yaml
name: Flutter Web Deploy to GitHub Pages

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  workflow_dispatch:
    inputs:
      deploy_message:
        description: 'Deployment message'
        required: false
        default: 'Manual deployment'

# Permisos necesarios para GitHub Pages
permissions:
  contents: write
  pages: write
  id-token: write

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    # 1. Checkout del código
    - name: Checkout repository
      uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Necesario para obtener todas las ramas
    
    # 2. Configurar Flutter con versión compatible
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.32.4'  # Versión estable con Dart 3.8.1+
        channel: 'stable'
        cache: true
        cache-key: 'flutter-:os:-:channel:-:version:-:arch:-:hash:'
    
    # 3. Verificar versiones
    - name: Verify Flutter and Dart versions
      run: |
        flutter --version
        dart --version
        flutter doctor -v
    
    # 4. Limpiar caché si es necesario
    - name: Clean Flutter
      run: flutter clean
    
    # 5. Obtener dependencias
    - name: Get dependencies
      run: flutter pub get
    
    # 6. Analizar código (opcional pero recomendado)
    - name: Analyze code
      run: flutter analyze --no-fatal-infos --no-fatal-warnings
      continue-on-error: true
    
    # 7. Ejecutar tests (opcional pero recomendado)
    - name: Run tests
      run: flutter test --no-pub
      continue-on-error: true
    
    # 8. Build para web - SIN parámetros obsoletos
    - name: Build web
      run: |
        # Obtener nombre del repositorio para base-href
        REPO_NAME=$(echo ${{ github.repository }} | cut -d'/' -f2)
        echo "Building with base-href: /$REPO_NAME/"
        
        # Build sin --web-renderer (obsoleto en Flutter 3.32+)
        flutter build web --release --base-href "/$REPO_NAME/"
        
        # Verificar que el build fue exitoso
        if [ ! -d "build/web" ]; then
          echo "Error: build/web directory not found!"
          exit 1
        fi
        
        # Listar archivos generados
        echo "Build completed. Files generated:"
        ls -la build/web/
    
    # 9. Preparar archivos para GitHub Pages
    - name: Prepare for GitHub Pages
      run: |
        # Añadir archivo .nojekyll para evitar procesamiento Jekyll
        touch build/web/.nojekyll
        
        # Crear 404.html para manejar rutas del cliente
        cp build/web/index.html build/web/404.html
        
        # Añadir CNAME si se usa dominio personalizado (opcional)
        # echo "tudominio.com" > build/web/CNAME
    
    # 10. Deploy a GitHub Pages
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v4
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./build/web
        publish_branch: gh-pages
        force_orphan: false  # Mantener historial de deploys
        user_name: 'github-actions[bot]'
        user_email: 'github-actions[bot]@users.noreply.github.com'
        commit_message: |
          Deploy Flutter web app to GitHub Pages
          
          Triggered by: ${{ github.event_name }}
          Commit: ${{ github.sha }}
          Message: ${{ github.event.inputs.deploy_message || 'Automated deployment' }}
    
    # 11. Verificar deploy
    - name: Verify deployment
      run: |
        REPO_NAME=$(echo ${{ github.repository }} | cut -d'/' -f2)
        GITHUB_USER=$(echo ${{ github.repository }} | cut -d'/' -f1)
        DEPLOY_URL="https://${GITHUB_USER}.github.io/${REPO_NAME}/"
        
        echo "Deployment should be available at: $DEPLOY_URL"
        echo "Note: GitHub Pages may take 1-10 minutes to update"
        
        # Esperar un momento antes de verificar
        sleep 30
        
        # Intentar verificar si el sitio responde
        if curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL" | grep -q "200\|301\|302"; then
          echo "✅ Site is responding!"
        else
          echo "⏳ Site may still be deploying. Please check in a few minutes."
        fi
```

#### 3.3 Crear scripts de soporte

**Archivo**: `scripts/setup-github-pages.sh`
```bash
#!/bin/bash

# setup-github-pages.sh - Configuración inicial automatizada

set -e  # Salir si hay algún error

echo "🚀 Iniciando configuración de GitHub Pages para Flutter Web"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar comandos
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 no está instalado${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ $1 está instalado${NC}"
    fi
}

# 1. Verificar prerequisitos
echo "📋 Verificando prerequisitos..."
check_command git
check_command flutter

# 2. Verificar versión de Flutter
echo "📦 Verificando versión de Flutter..."
FLUTTER_VERSION=$(flutter --version | grep "Flutter" | cut -d' ' -f2)
REQUIRED_VERSION="3.32.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$FLUTTER_VERSION" | sort -V | head -n1)" = "$REQUIRED_VERSION" ]; then 
    echo -e "${GREEN}✅ Flutter $FLUTTER_VERSION es compatible${NC}"
else
    echo -e "${RED}❌ Flutter $FLUTTER_VERSION es muy antiguo. Se requiere 3.32.0+${NC}"
    exit 1
fi

# 3. Verificar estructura del proyecto
echo "🔍 Verificando estructura del proyecto..."
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ No se encontró pubspec.yaml. ¿Estás en la raíz del proyecto Flutter?${NC}"
    exit 1
fi

# 4. Crear rama gh-pages si no existe
echo "🌿 Configurando rama gh-pages..."
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo -e "${YELLOW}⚠️  Rama gh-pages ya existe${NC}"
else
    echo "Creando rama gh-pages..."
    git checkout --orphan gh-pages
    git rm -rf . 2>/dev/null || true
    echo "<!DOCTYPE html><html><body><h1>GitHub Pages Initialized</h1></body></html>" > index.html
    git add index.html
    git commit -m "Initial gh-pages setup"
    git push origin gh-pages
    git checkout main 2>/dev/null || git checkout master
    echo -e "${GREEN}✅ Rama gh-pages creada${NC}"
fi

# 5. Crear estructura de directorios
echo "📁 Creando estructura de directorios..."
mkdir -p .github/workflows
mkdir -p scripts
mkdir -p web

# 6. Verificar archivo .gitignore
echo "📝 Verificando .gitignore..."
if ! grep -q "build/" .gitignore 2>/dev/null; then
    echo "build/" >> .gitignore
    echo -e "${GREEN}✅ Añadido build/ a .gitignore${NC}"
fi

# 7. Crear archivo .nojekyll en web/
touch web/.nojekyll
echo -e "${GREEN}✅ Creado web/.nojekyll${NC}"

# 8. Obtener información del repositorio
REPO_URL=$(git config --get remote.origin.url)
REPO_NAME=$(basename -s .git "$REPO_URL")
GITHUB_USER=$(echo "$REPO_URL" | sed -n 's/.*github.com[:/]\([^/]*\)\/.*/\1/p')

echo ""
echo "================================================"
echo -e "${GREEN}✅ Configuración inicial completada${NC}"
echo "================================================"
echo ""
echo "📌 Próximos pasos:"
echo ""
echo "1. Ve a: https://github.com/$GITHUB_USER/$REPO_NAME/settings/pages"
echo "2. En 'Source': Selecciona 'Deploy from a branch'"
echo "3. En 'Branch': Selecciona 'gh-pages'"
echo "4. En 'Folder': Selecciona '/ (root)'"
echo "5. Click en 'Save'"
echo ""
echo "6. Copia el workflow a .github/workflows/flutter-web-deploy.yml"
echo "7. Haz commit y push de los cambios"
echo ""
echo "Tu sitio estará disponible en:"
echo -e "${YELLOW}https://$GITHUB_USER.github.io/$REPO_NAME/${NC}"
echo ""
```

**Archivo**: `scripts/verify-deployment.sh`
```bash
#!/bin/bash

# verify-deployment.sh - Verificar estado del despliegue

set -e

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Obtener información del repo
REPO_URL=$(git config --get remote.origin.url)
REPO_NAME=$(basename -s .git "$REPO_URL")
GITHUB_USER=$(echo "$REPO_URL" | sed -n 's/.*github.com[:/]\([^/]*\)\/.*/\1/p')
DEPLOY_URL="https://$GITHUB_USER.github.io/$REPO_NAME/"

echo "🔍 Verificando despliegue en GitHub Pages..."
echo "URL: $DEPLOY_URL"
echo ""

# Verificar workflows recientes
echo "📊 Últimos workflows ejecutados:"
if command -v gh &> /dev/null; then
    gh run list --limit 5 --workflow=flutter-web-deploy.yml
else
    echo -e "${YELLOW}GitHub CLI no instalado. Instálalo con: brew install gh${NC}"
fi

echo ""
echo "🌐 Verificando disponibilidad del sitio..."

# Hacer múltiples intentos
MAX_ATTEMPTS=10
ATTEMPT=1
SUCCESS=false

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    echo -n "Intento $ATTEMPT/$MAX_ATTEMPTS: "
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL")
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
        echo -e "${GREEN}✅ Sitio disponible (HTTP $HTTP_CODE)${NC}"
        SUCCESS=true
        break
    else
        echo -e "${YELLOW}⏳ No disponible aún (HTTP $HTTP_CODE)${NC}"
        
        if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
            echo "Esperando 30 segundos..."
            sleep 30
        fi
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
done

echo ""

if [ "$SUCCESS" = true ]; then
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}✅ DESPLIEGUE EXITOSO${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo "Tu aplicación está disponible en:"
    echo -e "${GREEN}$DEPLOY_URL${NC}"
    echo ""
    
    # Intentar abrir en el navegador
    if command -v open &> /dev/null; then
        echo "Abriendo en el navegador..."
        open "$DEPLOY_URL"
    elif command -v xdg-open &> /dev/null; then
        echo "Abriendo en el navegador..."
        xdg-open "$DEPLOY_URL"
    fi
else
    echo -e "${RED}================================================${NC}"
    echo -e "${RED}❌ DESPLIEGUE NO VERIFICADO${NC}"
    echo -e "${RED}================================================${NC}"
    echo ""
    echo "Posibles causas:"
    echo "1. GitHub Pages aún está procesando (puede tardar hasta 10 minutos)"
    echo "2. La configuración de Pages no está correcta"
    echo "3. El workflow falló"
    echo ""
    echo "Verificaciones recomendadas:"
    echo "1. Revisa: https://github.com/$GITHUB_USER/$REPO_NAME/settings/pages"
    echo "2. Revisa: https://github.com/$GITHUB_USER/$REPO_NAME/actions"
    echo "3. Ejecuta: gh run view --log"
fi
```

**Archivo**: `scripts/emergency-deploy.sh`
```bash
#!/bin/bash

# emergency-deploy.sh - Deploy manual de emergencia

set -e

echo "🚨 DEPLOY MANUAL DE EMERGENCIA"
echo "================================"
echo ""
echo "Este script realizará un deploy manual sin usar GitHub Actions"
echo ""

# Verificar que estamos en la rama correcta
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo "⚠️  No estás en main/master. ¿Continuar? (y/n)"
    read -r CONFIRM
    if [ "$CONFIRM" != "y" ]; then
        exit 0
    fi
fi

# 1. Build local
echo "🔨 Construyendo aplicación web..."
flutter clean
flutter pub get
flutter build web --release --base-href "/$(basename $(pwd))/"

# 2. Verificar build
if [ ! -d "build/web" ]; then
    echo "❌ Error: No se pudo construir la aplicación"
    exit 1
fi

# 3. Preparar archivos
echo "📦 Preparando archivos..."
touch build/web/.nojekyll
cp build/web/index.html build/web/404.html

# 4. Crear commit temporal
echo "💾 Guardando estado actual..."
git stash push -m "Emergency deploy backup"

# 5. Cambiar a gh-pages
echo "🔄 Cambiando a rama gh-pages..."
git checkout gh-pages

# 6. Limpiar rama
git rm -rf . 2>/dev/null || true

# 7. Copiar build
cp -r build/web/* .
cp build/web/.nojekyll .

# 8. Commit y push
echo "📤 Subiendo a GitHub Pages..."
git add -A
git commit -m "Emergency deploy: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin gh-pages --force

# 9. Volver a rama original
echo "🔙 Volviendo a rama $CURRENT_BRANCH..."
git checkout "$CURRENT_BRANCH"

# 10. Restaurar cambios
if git stash list | grep -q "Emergency deploy backup"; then
    git stash pop
fi

echo ""
echo "✅ Deploy manual completado"
echo "El sitio debería estar disponible en 1-2 minutos"
```

### PASO 4: Configuración de Dependencias

**Archivo**: `pubspec.yaml` (sección relevante)
```yaml
environment:
  sdk: ^3.8.1
  flutter: ">=3.32.0"

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0  # NO cambiar a v5 hasta Flutter 3.35+
```

### PASO 5: Comandos de Ejecución

#### Ejecución Completa Automatizada
```bash
# 1. Setup inicial (solo primera vez)
chmod +x scripts/*.sh
./scripts/setup-github-pages.sh

# 2. Configurar GitHub Pages manualmente según instrucciones

# 3. Hacer commit del workflow
git add .github/workflows/flutter-web-deploy.yml
git add scripts/
git commit -m "Add GitHub Pages deployment workflow"
git push origin main

# 4. Verificar despliegue
./scripts/verify-deployment.sh
```

#### Comandos Individuales para Testing
```bash
# Build local
flutter build web --release --base-href "/repo-name/"

# Servir localmente
cd build/web
python3 -m http.server 8000
# Abrir: http://localhost:8000

# Ver logs del workflow
gh run list --workflow=flutter-web-deploy.yml
gh run view [RUN_ID] --log

# Deploy manual si falla Actions
./scripts/emergency-deploy.sh
```

## Checklist de Verificación Automatizable

```bash
#!/bin/bash
# checklist.sh - Verificación automatizada pre-deploy

CHECKS_PASSED=0
CHECKS_FAILED=0

check() {
    if eval "$2"; then
        echo "✅ $1"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo "❌ $1"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
}

echo "🔍 Ejecutando checklist automatizado..."
echo ""

# Verificaciones
check "Flutter instalado" "command -v flutter &> /dev/null"
check "Flutter versión 3.32+" "flutter --version | grep -E '3\.(3[2-9]|[4-9][0-9])'"
check "Archivo pubspec.yaml existe" "[ -f pubspec.yaml ]"
check "Directorio .github/workflows existe" "[ -d .github/workflows ]"
check "Workflow de deploy existe" "[ -f .github/workflows/flutter-web-deploy.yml ]"
check "Rama gh-pages existe" "git show-ref --verify --quiet refs/remotes/origin/gh-pages"
check "No hay cambios sin commit" "[ -z \"$(git status --porcelain)\" ]"
check "flutter_lints es v4" "grep -q 'flutter_lints: ^4' pubspec.yaml"
check "SDK constraint correcto" "grep -q 'sdk: ^3.8' pubspec.yaml"
check "Web platform habilitado" "[ -d web ]"

echo ""
echo "================================"
echo "Resultados: ✅ $CHECKS_PASSED | ❌ $CHECKS_FAILED"
echo "================================"

if [ $CHECKS_FAILED -eq 0 ]; then
    echo "🎉 Todas las verificaciones pasaron. Listo para deploy!"
    exit 0
else
    echo "⚠️  Hay verificaciones fallidas. Revisa antes de continuar."
    exit 1
fi
```

## Solución de Problemas Comunes

### Problema: "Permission denied" al ejecutar scripts
```bash
chmod +x scripts/*.sh
```

### Problema: "flutter: command not found"
```bash
# macOS/Linux
export PATH="$PATH:$HOME/flutter/bin"

# Windows
set PATH=%PATH%;C:\flutter\bin
```

### Problema: "gh-pages branch does not exist"
```bash
git checkout --orphan gh-pages
git rm -rf .
echo "Init" > index.html
git add index.html
git commit -m "Init gh-pages"
git push origin gh-pages
git checkout main
```

### Problema: "404 después del deploy"
1. Verificar en Settings → Pages que esté configurado gh-pages
2. Esperar 10 minutos (primera vez puede tardar más)
3. Verificar que base-href coincida con nombre del repo

## Versiones Exactas que Funcionan

| Componente | Versión | Notas |
|------------|---------|-------|
| Flutter | 3.32.4 | Incluye Dart 3.8.1 |
| Dart | 3.8.1+ | Mínimo requerido |
| flutter_lints | 4.0.0 | NO usar v5 |
| GitHub Actions | v4 | actions/checkout@v4 |
| Ubuntu Runner | ubuntu-latest | Ubuntu 22.04 |

## Por Qué de Cada Decisión

1. **Flutter 3.32.4**: Versión estable con Dart 3.8.1+, sin bugs conocidos de web
2. **No --web-renderer**: Parámetro obsoleto que causa error 64
3. **flutter_lints v4**: v5 requiere Dart SDK más nuevo, causa conflictos
4. **force_orphan: false**: Mantener historial de deploys para rollback
5. **.nojekyll**: GitHub Pages no procese archivos con _ (comunes en Flutter)
6. **404.html**: Manejo de rutas del cliente en SPA
7. **base-href**: Necesario para subdirectorio en github.io

## Comandos Copy-Paste Listos

### Setup Completo Nuevo Proyecto
```bash
# Copiar y pegar todo este bloque
git clone https://github.com/TU_USUARIO/TU_REPO.git && \
cd TU_REPO && \
mkdir -p .github/workflows scripts web && \
touch web/.nojekyll && \
git checkout --orphan gh-pages && \
git rm -rf . && \
echo "Init" > index.html && \
git add index.html && \
git commit -m "Init gh-pages" && \
git push origin gh-pages && \
git checkout main
```

### Deploy Rápido
```bash
# Después de configurar todo
git add . && \
git commit -m "Update" && \
git push origin main && \
echo "Deploy iniciado. Verificar en 2-5 minutos"
```

### Verificación Rápida
```bash
curl -s -o /dev/null -w "%{http_code}" \
"https://$(git config --get remote.origin.url | \
sed -n 's/.*github.com[:/]\([^/]*\)\/\(.*\)\.git/\1.github.io\/\2/p')/"
```

---

**Documento generado**: 2025-08-09
**Versión**: 1.0.0
**Probado con**: ALMA Project