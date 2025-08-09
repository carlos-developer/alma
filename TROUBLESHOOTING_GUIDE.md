# TROUBLESHOOTING GUIDE - Flutter GitHub Pages Deployment

## Introducción

Esta guía documenta todos los errores encontrados durante el despliegue de aplicaciones Flutter en GitHub Pages, sus causas raíz, soluciones probadas y métodos de prevención. Está organizada por categorías para facilitar la resolución rápida de problemas.

## Índice de Errores

1. [Errores de Versión y Compatibilidad](#1-errores-de-versión-y-compatibilidad)
2. [Errores de Build](#2-errores-de-build)
3. [Errores de GitHub Pages](#3-errores-de-github-pages)
4. [Errores de GitHub Actions](#4-errores-de-github-actions)
5. [Errores de Configuración](#5-errores-de-configuración)

---

## 1. Errores de Versión y Compatibilidad

### Error 1.1: Incompatibilidad de Dart SDK

#### Síntomas
```
The current Dart SDK version is 3.5.4.
Because alma requires SDK version ^3.8.1, version solving failed.
pub get failed (1; Because alma requires SDK version ^3.8.1, version solving failed.)
```

#### Causa Raíz
- El workflow usa una versión de Flutter que incluye Dart SDK antiguo
- Flutter 3.24.0 incluye Dart 3.5.4, pero el proyecto requiere Dart 3.8.1+

#### Solución Inmediata
```yaml
# En .github/workflows/flutter-web-deploy.yml
- uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.32.4'  # Cambiar de 3.24.0
    channel: 'stable'
```

#### Prevención
```bash
# Script de verificación pre-deploy
#!/bin/bash
DART_VERSION=$(dart --version 2>&1 | grep -oP 'Dart SDK version: \K[0-9.]+')
REQUIRED="3.8.1"

if [ "$(printf '%s\n' "$REQUIRED" "$DART_VERSION" | sort -V | head -n1)" != "$REQUIRED" ]; then
    echo "Error: Dart $DART_VERSION es muy antiguo. Actualiza Flutter."
    exit 1
fi
```

#### Diagnóstico
```bash
# Verificar versiones localmente
flutter doctor -v | grep -A 2 "Dart SDK"
flutter --version

# Ver qué versión de Dart incluye cada Flutter
# Flutter 3.32.0+ incluye Dart 3.8.1+
# Flutter 3.24.0 incluye Dart 3.5.4
```

---

### Error 1.2: Incompatibilidad de flutter_lints

#### Síntomas
```
Because alma depends on flutter_lints ^4.0.0 which doesn't match any versions, version solving failed.
```

#### Causa Raíz
- flutter_lints v5 requiere Dart SDK más nuevo que el disponible
- Conflicto entre versión de linter y SDK

#### Solución Inmediata
```yaml
# En pubspec.yaml
dev_dependencies:
  flutter_lints: ^4.0.0  # Downgrade desde ^5.0.0
```

#### Prevención
```yaml
# Fijar versiones exactas en pubspec.yaml
dev_dependencies:
  flutter_lints: 4.0.0  # Sin ^ para evitar actualizaciones automáticas
```

#### Diagnóstico
```bash
# Verificar compatibilidad de paquetes
flutter pub deps --no-dev | grep flutter_lints
flutter pub outdated

# Verificar qué versión es compatible
flutter pub add flutter_lints --dev
```

---

## 2. Errores de Build

### Error 2.1: Parámetro --web-renderer Obsoleto

#### Síntomas
```
Could not find an option named "web-renderer".
Error: Process completed with exit code 64.
```

#### Causa Raíz
- Flutter 3.32+ deprecó el parámetro --web-renderer
- El renderer ahora se auto-selecciona o configura en web/index.html

#### Solución Inmediata
```bash
# ANTES (incorrecto)
flutter build web --web-renderer canvaskit --base-href /alma/

# DESPUÉS (correcto)
flutter build web --base-href /alma/
```

#### Prevención
```bash
# Verificar parámetros disponibles antes de usar
flutter build web --help | grep renderer

# Si necesitas forzar un renderer, hazlo en web/index.html
```

#### Configuración Alternativa del Renderer
```html
<!-- En web/index.html -->
<script>
  window.flutterWebRenderer = "canvaskit"; // o "html"
</script>
```

#### Diagnóstico
```bash
# Ver todos los parámetros disponibles
flutter build web --help

# Verificar versión de Flutter para saber qué parámetros soporta
flutter --version
```

---

### Error 2.2: Build Directory Not Found

#### Síntomas
```
Error: build/web directory not found!
cp: cannot stat 'build/web/*': No such file or directory
```

#### Causa Raíz
- El comando flutter build web falló silenciosamente
- Permisos insuficientes
- Falta de limpieza de caché

#### Solución Inmediata
```bash
# Limpiar y reconstruir
flutter clean
flutter pub get
flutter build web --release

# Verificar que existe
ls -la build/web/
```

#### Prevención
```bash
# En scripts, siempre verificar
if [ ! -d "build/web" ]; then
    echo "Error: Build failed"
    exit 1
fi
```

#### Diagnóstico
```bash
# Build verbose para ver errores
flutter build web --verbose

# Verificar espacio en disco
df -h

# Verificar permisos
ls -la build/
```

---

## 3. Errores de GitHub Pages

### Error 3.1: 404 - Página No Encontrada

#### Síntomas
- Deploy exitoso pero sitio muestra 404
- GitHub Actions verde pero sitio no accesible

#### Causa Raíz
- GitHub Pages configurado para servir desde rama incorrecta
- base-href incorrecto
- Archivos no en la ubicación esperada

#### Solución Inmediata
1. Ir a Settings → Pages
2. Source: "Deploy from a branch"
3. Branch: "gh-pages" (no main)
4. Folder: "/ (root)"
5. Save

#### Prevención
```yaml
# Verificar configuración con GitHub CLI
gh api repos/:owner/:repo/pages

# Script de verificación
#!/bin/bash
CONFIG=$(gh api repos/:owner/:repo/pages 2>/dev/null)
if echo "$CONFIG" | grep -q '"source":{"branch":"gh-pages"'; then
    echo "✅ Configuración correcta"
else
    echo "❌ Pages mal configurado"
fi
```

#### Diagnóstico
```bash
# Verificar contenido de gh-pages
git checkout gh-pages
ls -la
git checkout main

# Verificar URL correcta
echo "https://$(git config --get remote.origin.url | \
  sed -n 's/.*github.com[:/]\([^/]*\)\/\(.*\)\.git/\1.github.io\/\2/p')/"
```

---

### Error 3.2: Rama gh-pages No Existe

#### Síntomas
```
error: pathspec 'gh-pages' did not match any file(s) known to git
! [rejected] gh-pages -> gh-pages (fetch first)
```

#### Causa Raíz
- La rama gh-pages debe existir antes del primer deploy
- GitHub Actions no crea automáticamente ramas nuevas

#### Solución Inmediata
```bash
# Crear rama huérfana gh-pages
git checkout --orphan gh-pages
git rm -rf .
echo "Initializing GitHub Pages" > index.html
git add index.html
git commit -m "Initial gh-pages"
git push origin gh-pages
git checkout main
```

#### Prevención
```bash
# Script de inicialización
#!/bin/bash
if ! git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "Creating gh-pages branch..."
    git checkout --orphan gh-pages
    git rm -rf .
    echo "Init" > index.html
    git add index.html
    git commit -m "Init"
    git push origin gh-pages
    git checkout main
fi
```

#### Diagnóstico
```bash
# Ver todas las ramas
git branch -a

# Verificar si existe remotamente
git ls-remote --heads origin gh-pages
```

---

### Error 3.3: Archivos con _ No Se Sirven

#### Síntomas
- Archivos como _flutter.js devuelven 404
- Aplicación no carga, consola muestra errores de archivos faltantes

#### Causa Raíz
- Jekyll (procesador de GitHub Pages) ignora archivos que empiezan con _

#### Solución Inmediata
```bash
# Añadir archivo .nojekyll en el root del build
touch build/web/.nojekyll
```

#### Prevención
```yaml
# En workflow, siempre añadir
- name: Prepare for GitHub Pages
  run: |
    touch build/web/.nojekyll
```

#### Diagnóstico
```bash
# Verificar si .nojekyll existe en gh-pages
git checkout gh-pages
ls -la | grep nojekyll
git checkout main
```

---

## 4. Errores de GitHub Actions

### Error 4.1: Permission Denied

#### Síntomas
```
Error: Permission denied to github-actions[bot]
fatal: unable to access repository
```

#### Causa Raíz
- Permisos insuficientes en el workflow
- GITHUB_TOKEN sin permisos de escritura

#### Solución Inmediata
```yaml
# En workflow, añadir permisos
permissions:
  contents: write
  pages: write
  id-token: write
```

#### Prevención
```yaml
# Configurar permisos mínimos necesarios
permissions:
  contents: write  # Para push a gh-pages
  pages: write     # Para configurar Pages
  id-token: write  # Para OIDC
```

#### Diagnóstico
```bash
# Verificar permisos del token
gh auth status

# Ver permisos del workflow
gh workflow view flutter-web-deploy.yml
```

---

### Error 4.2: Workflow No Se Ejecuta

#### Síntomas
- Push a main pero workflow no inicia
- No aparece en Actions tab

#### Causa Raíz
- Workflow mal formateado (YAML inválido)
- Archivo en ubicación incorrecta
- Branch protection rules

#### Solución Inmediata
```bash
# Validar YAML
yamllint .github/workflows/flutter-web-deploy.yml

# Verificar ubicación
ls -la .github/workflows/

# Trigger manual
gh workflow run flutter-web-deploy.yml
```

#### Prevención
```yaml
# Añadir workflow_dispatch para testing
on:
  workflow_dispatch:
  push:
    branches: [main, master]
```

#### Diagnóstico
```bash
# Ver todos los workflows
gh workflow list

# Ver runs recientes
gh run list

# Ver logs de un run específico
gh run view [RUN_ID] --log
```

---

## 5. Errores de Configuración

### Error 5.1: Base HREF Incorrecto

#### Síntomas
- Sitio carga pero sin estilos
- Errores 404 para assets
- URLs apuntan a github.io root en lugar de subdirectorio

#### Causa Raíz
- base-href no coincide con estructura de GitHub Pages
- Falta / al final del base-href

#### Solución Inmediata
```bash
# Formato correcto (nota las / al inicio y final)
flutter build web --base-href "/nombre-repo/"

# NO usar
flutter build web --base-href "nombre-repo"  # Falta /
flutter build web --base-href "/nombre-repo"  # Falta / final
```

#### Prevención
```bash
# Obtener nombre automáticamente
REPO_NAME=$(basename $(git config --get remote.origin.url) .git)
flutter build web --base-href "/$REPO_NAME/"
```

#### Diagnóstico
```html
<!-- Verificar en build/web/index.html -->
<base href="/nombre-repo/">
<!-- Debe tener / al inicio y final -->
```

---

## Scripts de Diagnóstico Completos

### Script 1: Diagnóstico General
```bash
#!/bin/bash
# diagnostic.sh - Diagnóstico completo del entorno

echo "🔍 DIAGNÓSTICO DE FLUTTER WEB DEPLOYMENT"
echo "========================================"
echo ""

# 1. Versiones
echo "📦 VERSIONES:"
flutter --version | head -n 1
dart --version
echo ""

# 2. Proyecto
echo "📁 PROYECTO:"
if [ -f pubspec.yaml ]; then
    echo "✅ pubspec.yaml encontrado"
    grep "sdk:" pubspec.yaml
    grep "flutter_lints:" pubspec.yaml
else
    echo "❌ pubspec.yaml no encontrado"
fi
echo ""

# 3. Git
echo "🌿 GIT:"
echo "Rama actual: $(git branch --show-current)"
echo "Ramas remotas:"
git branch -r | grep -E "(main|master|gh-pages)"
echo ""

# 4. GitHub Pages
echo "🌐 GITHUB PAGES:"
REPO_URL=$(git config --get remote.origin.url)
REPO_NAME=$(basename -s .git "$REPO_URL")
GITHUB_USER=$(echo "$REPO_URL" | sed -n 's/.*github.com[:/]\([^/]*\)\/.*/\1/p')
echo "URL esperada: https://$GITHUB_USER.github.io/$REPO_NAME/"

if command -v gh &> /dev/null; then
    echo "Configuración actual:"
    gh api repos/$GITHUB_USER/$REPO_NAME/pages 2>/dev/null || echo "Pages no configurado"
fi
echo ""

# 5. Workflows
echo "⚙️ WORKFLOWS:"
if [ -f .github/workflows/flutter-web-deploy.yml ]; then
    echo "✅ Workflow encontrado"
    if command -v gh &> /dev/null; then
        echo "Últimas ejecuciones:"
        gh run list --limit 3
    fi
else
    echo "❌ Workflow no encontrado"
fi
echo ""

# 6. Build
echo "🔨 BUILD:"
if [ -d build/web ]; then
    echo "✅ build/web existe"
    echo "Archivos: $(ls -1 build/web | wc -l)"
    echo "Tamaño: $(du -sh build/web | cut -f1)"
else
    echo "❌ build/web no existe"
fi
```

### Script 2: Fix Automático
```bash
#!/bin/bash
# autofix.sh - Intenta corregir problemas comunes automáticamente

echo "🔧 AUTO-FIX PARA FLUTTER WEB DEPLOYMENT"
echo "========================================"
echo ""

FIXED=0

# 1. Verificar Flutter version
echo "Verificando versión de Flutter..."
FLUTTER_VERSION=$(flutter --version | grep "Flutter" | cut -d' ' -f2)
if [ "$(printf '%s\n' "3.32.0" "$FLUTTER_VERSION" | sort -V | head -n1)" != "3.32.0" ]; then
    echo "⚠️  Flutter $FLUTTER_VERSION es antiguo. Actualiza a 3.32.0+"
    echo "Ejecuta: flutter upgrade"
else
    echo "✅ Flutter $FLUTTER_VERSION es compatible"
fi
echo ""

# 2. Fix flutter_lints
echo "Verificando flutter_lints..."
if grep -q "flutter_lints: ^5" pubspec.yaml 2>/dev/null; then
    echo "🔧 Downgrading flutter_lints a v4..."
    sed -i.bak 's/flutter_lints: ^5/flutter_lints: ^4/' pubspec.yaml
    flutter pub get
    FIXED=$((FIXED + 1))
fi
echo ""

# 3. Crear gh-pages si no existe
echo "Verificando rama gh-pages..."
if ! git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "🔧 Creando rama gh-pages..."
    git checkout --orphan gh-pages
    git rm -rf . 2>/dev/null || true
    echo "Init" > index.html
    git add index.html
    git commit -m "Init gh-pages"
    git push origin gh-pages
    git checkout main 2>/dev/null || git checkout master
    FIXED=$((FIXED + 1))
fi
echo ""

# 4. Crear .nojekyll
echo "Verificando .nojekyll..."
if [ ! -f web/.nojekyll ]; then
    echo "🔧 Creando web/.nojekyll..."
    touch web/.nojekyll
    FIXED=$((FIXED + 1))
fi
echo ""

# 5. Crear estructura de directorios
echo "Verificando estructura de directorios..."
if [ ! -d .github/workflows ]; then
    echo "🔧 Creando .github/workflows..."
    mkdir -p .github/workflows
    FIXED=$((FIXED + 1))
fi
echo ""

echo "========================================"
echo "Problemas corregidos: $FIXED"
if [ $FIXED -gt 0 ]; then
    echo "⚠️  Ejecuta 'git add .' y 'git commit' para guardar los cambios"
fi
```

### Script 3: Monitor en Tiempo Real
```bash
#!/bin/bash
# monitor.sh - Monitoreo en tiempo real del despliegue

echo "📊 MONITOR DE DESPLIEGUE EN TIEMPO REAL"
echo "========================================"
echo ""

# Configuración
REPO_URL=$(git config --get remote.origin.url)
REPO_NAME=$(basename -s .git "$REPO_URL")
GITHUB_USER=$(echo "$REPO_URL" | sed -n 's/.*github.com[:/]\([^/]*\)\/.*/\1/p')
DEPLOY_URL="https://$GITHUB_USER.github.io/$REPO_NAME/"

# Función para verificar estado
check_status() {
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL")
    echo -n "$(date '+%H:%M:%S') - "
    
    case $HTTP_CODE in
        200)
            echo "✅ Sitio en línea (HTTP 200)"
            return 0
            ;;
        404)
            echo "❌ No encontrado (HTTP 404)"
            ;;
        301|302)
            echo "↗️ Redirección (HTTP $HTTP_CODE)"
            ;;
        000)
            echo "⏳ Sin respuesta"
            ;;
        *)
            echo "⚠️  HTTP $HTTP_CODE"
            ;;
    esac
    return 1
}

# Monitor loop
echo "Monitoreando: $DEPLOY_URL"
echo "Presiona Ctrl+C para detener"
echo ""

while true; do
    if check_status; then
        echo ""
        echo "🎉 ¡Despliegue exitoso!"
        echo "Tu sitio está disponible en: $DEPLOY_URL"
        
        # Intentar abrir en navegador
        if command -v open &> /dev/null; then
            open "$DEPLOY_URL"
        elif command -v xdg-open &> /dev/null; then
            xdg-open "$DEPLOY_URL"
        fi
        break
    fi
    sleep 10
done
```

## Matriz de Soluciones Rápidas

| Síntoma | Causa Probable | Solución Rápida |
|---------|---------------|-----------------|
| SDK version mismatch | Flutter antiguo | `flutter-version: '3.32.4'` |
| Exit code 64 | --web-renderer obsoleto | Remover parámetro |
| 404 en GitHub Pages | Branch incorrecta | Settings → gh-pages |
| flutter_lints fails | Versión incompatible | Usar v4.0.0 |
| Permission denied | Falta permissions en workflow | Añadir `contents: write` |
| Archivos con _ no cargan | Jekyll processing | Añadir `.nojekyll` |
| Build no se encuentra | Build falló | `flutter clean && flutter build web` |
| gh-pages not found | Rama no existe | Crear con `git checkout --orphan` |

## Comandos de Emergencia

```bash
# Reset completo y rebuild
flutter clean && \
rm -rf build/ && \
flutter pub get && \
flutter build web --release --base-href "/$(basename $(pwd))/"

# Force push a gh-pages
git checkout gh-pages && \
git rm -rf . && \
cp -r ../backup/build/web/* . && \
git add -A && \
git commit -m "Force deploy" && \
git push --force origin gh-pages

# Rollback a versión anterior
git checkout gh-pages && \
git reset --hard HEAD~1 && \
git push --force origin gh-pages
```

---

**Documento generado**: 2025-08-09
**Versión**: 1.0.0
**Última actualización**: 2025-08-09