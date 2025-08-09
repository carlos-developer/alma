#!/bin/bash

# quick-deploy.sh - Deploy rápido sin errores conocidos
# Version: 2.0.0
# Optimizado para evitar todos los errores documentados

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${GREEN}${BOLD}🚀 QUICK DEPLOY - Flutter to GitHub Pages${NC}"
echo "==========================================="

# 1. Verificación rápida de versiones
echo "Verificando entorno..."
FLUTTER_VERSION=$(flutter --version | grep "Flutter" | cut -d' ' -f2)
if [ "$(printf '%s\n' "3.32.0" "$FLUTTER_VERSION" | sort -V | head -n1)" != "3.32.0" ]; then
    echo -e "${RED}Error: Flutter $FLUTTER_VERSION es muy antiguo${NC}"
    echo "Ejecuta: flutter upgrade"
    exit 1
fi

# 2. Información del repositorio
REPO_NAME=$(basename $(pwd))
REPO_URL=$(git config --get remote.origin.url)
GITHUB_USER=$(echo "$REPO_URL" | sed -n 's/.*github.com[:/]\([^/]*\)\/.*/\1/p')

echo -e "${GREEN}Repositorio: $REPO_NAME${NC}"
echo -e "${GREEN}Usuario: $GITHUB_USER${NC}"

# 3. Build optimizado
echo ""
echo "Construyendo aplicación..."
flutter clean
flutter pub get
flutter build web --release --base-href "/$REPO_NAME/"

# 4. Verificar build
if [ ! -d "build/web" ]; then
    echo -e "${RED}Error: Build falló${NC}"
    exit 1
fi

# 5. Preparar archivos
echo "Preparando archivos..."
touch build/web/.nojekyll
cp build/web/index.html build/web/404.html
echo "$(date '+%Y-%m-%d %H:%M:%S')" > build/web/deploy-timestamp.txt

# 6. Deploy a gh-pages
echo "Desplegando a GitHub Pages..."

# Guardar branch actual
CURRENT_BRANCH=$(git branch --show-current)

# Verificar si gh-pages existe
if ! git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "Creando rama gh-pages..."
    git checkout --orphan gh-pages
    git rm -rf .
    echo "Init" > index.html
    git add index.html
    git commit -m "Initial gh-pages"
    git push origin gh-pages
    git checkout "$CURRENT_BRANCH"
fi

# Cambiar a gh-pages
git checkout gh-pages

# Limpiar y copiar nuevo build
find . -maxdepth 1 ! -name '.git' ! -name '.' ! -name '..' -exec rm -rf {} +
cp -r build/web/* .
cp build/web/.nojekyll .

# Commit y push
git add -A
git commit -m "Deploy: $(date '+%Y-%m-%d %H:%M:%S')" || echo "No hay cambios"
git push origin gh-pages

# Volver a rama original
git checkout "$CURRENT_BRANCH"

# 7. Verificación
echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Deploy completado exitosamente${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo "URL: https://$GITHUB_USER.github.io/$REPO_NAME/"
echo ""
echo "Nota: GitHub Pages puede tardar 1-10 minutos en actualizar"
echo ""

# Intentar verificar
sleep 5
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://$GITHUB_USER.github.io/$REPO_NAME/")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Sitio ya está respondiendo!${NC}"
else
    echo -e "${YELLOW}⏳ Sitio aún procesando (HTTP $HTTP_CODE)${NC}"
fi