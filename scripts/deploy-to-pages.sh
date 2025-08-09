#!/bin/bash

# Script de despliegue manual para ALMA a GitHub Pages
# Uso: ./scripts/deploy-to-pages.sh [--test]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}       ALMA - Deploy to GitHub Pages Script              ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Obtener información del repositorio
REPO_NAME=$(basename -s .git `git config --get remote.origin.url`)
REPO_OWNER=$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\/.*/\1/')
DEPLOY_URL="https://${REPO_OWNER}.github.io/${REPO_NAME}/"

echo -e "${YELLOW}📋 Información del proyecto:${NC}"
echo -e "   Repositorio: ${GREEN}${REPO_NAME}${NC}"
echo -e "   Owner: ${GREEN}${REPO_OWNER}${NC}"
echo -e "   URL de despliegue: ${GREEN}${DEPLOY_URL}${NC}"
echo ""

# Verificar branch actual
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$1" != "--test" ]; then
    echo -e "${YELLOW}⚠️  Advertencia: Estás en la branch '${CURRENT_BRANCH}', no en 'main'${NC}"
    echo -e "${YELLOW}   El despliegue automático solo funciona desde 'main'${NC}"
    echo -e "${YELLOW}   Usa --test para build de prueba local${NC}"
    echo ""
    read -p "¿Continuar de todos modos? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Despliegue cancelado${NC}"
        exit 1
    fi
fi

# Verificar estado de git
if [[ -n $(git status -s) ]]; then
    echo -e "${YELLOW}⚠️  Hay cambios sin commitear:${NC}"
    git status -s
    echo ""
    read -p "¿Continuar de todos modos? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Despliegue cancelado${NC}"
        exit 1
    fi
fi

# Fase 1: Preparación
echo -e "${BLUE}▶ FASE 1: Preparación del entorno${NC}"

# Habilitar Flutter web
echo "  ↳ Habilitando Flutter web..."
flutter config --enable-web > /dev/null 2>&1

# Verificar archivos necesarios
echo "  ↳ Verificando archivos de configuración..."
if [ ! -f "web/.nojekyll" ]; then
    echo "    Creando .nojekyll..."
    touch web/.nojekyll
fi

if [ ! -f "web/404.html" ]; then
    echo "    Creando 404.html..."
    cat > web/404.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>ALMA - Aprendizaje y Lógica para Mentes Activas</title>
  <script>
    const pathSegments = window.location.pathname.split('/').filter(Boolean);
    const repoName = pathSegments[0];
    if (pathSegments.length > 1) {
      window.location.href = '/' + repoName + '/';
    }
  </script>
</head>
<body>
  <p>Redirigiendo a ALMA...</p>
</body>
</html>
EOF
fi

# Fix temporal de dependencias si es necesario
if grep -q "flutter_lints: \^5\." pubspec.yaml; then
    echo "  ↳ Ajustando compatibilidad de dependencias..."
    sed -i.bak 's/flutter_lints: \^5\.0\.0/flutter_lints: \^4\.0\.0/' pubspec.yaml
    DEPS_MODIFIED=true
fi

# Fase 2: Instalación de dependencias
echo -e "${BLUE}▶ FASE 2: Instalación de dependencias${NC}"
flutter pub get

# Fase 3: Análisis y tests
echo -e "${BLUE}▶ FASE 3: Análisis de código y tests${NC}"

echo "  ↳ Analizando código..."
flutter analyze 2>/dev/null || echo -e "${YELLOW}    ⚠️  Advertencias en análisis (continuando...)${NC}"

echo "  ↳ Ejecutando tests..."
flutter test 2>/dev/null || echo -e "${YELLOW}    ⚠️  Algunos tests fallaron (continuando...)${NC}"

# Fase 4: Build
echo -e "${BLUE}▶ FASE 4: Construyendo aplicación web${NC}"

if [ "$1" == "--test" ]; then
    echo "  ↳ Modo TEST: construyendo para prueba local..."
    flutter build web --release --base-href /
else
    echo "  ↳ Construyendo para GitHub Pages..."
    flutter build web --release --base-href /${REPO_NAME}/ --web-renderer canvaskit
fi

# Copiar archivos necesarios
cp web/.nojekyll build/web/.nojekyll
cp web/404.html build/web/404.html

# Información del build
echo ""
echo -e "${GREEN}✅ Build completado exitosamente!${NC}"
echo -e "   Tamaño total: $(du -sh build/web/ | cut -f1)"
echo ""

# Fase 5: Test local (opcional)
if [ "$1" == "--test" ]; then
    echo -e "${BLUE}▶ FASE 5: Servidor de prueba local${NC}"
    echo -e "${YELLOW}Iniciando servidor en http://localhost:8080${NC}"
    echo -e "${YELLOW}Presiona Ctrl+C para detener${NC}"
    cd build/web
    python3 -m http.server 8080
    cd ../..
else
    # Instrucciones para despliegue
    echo -e "${BLUE}▶ Siguientes pasos para desplegar:${NC}"
    echo ""
    echo "  1. Asegúrate de estar en la branch main:"
    echo -e "     ${YELLOW}git checkout main${NC}"
    echo ""
    echo "  2. Mergea tus cambios si estás en develop:"
    echo -e "     ${YELLOW}git merge develop${NC}"
    echo ""
    echo "  3. Commitea cualquier cambio pendiente:"
    echo -e "     ${YELLOW}git add .${NC}"
    echo -e "     ${YELLOW}git commit -m 'feat: preparar despliegue a GitHub Pages'${NC}"
    echo ""
    echo "  4. Push a main para activar el despliegue automático:"
    echo -e "     ${YELLOW}git push origin main${NC}"
    echo ""
    echo -e "${GREEN}📌 Tu app estará disponible en:${NC}"
    echo -e "   ${BLUE}${DEPLOY_URL}${NC}"
    echo ""
    echo -e "${YELLOW}⏱️  El despliegue puede tardar 5-10 minutos${NC}"
fi

# Restaurar pubspec.yaml si fue modificado
if [ "$DEPS_MODIFIED" == "true" ]; then
    echo ""
    echo -e "${YELLOW}Nota: pubspec.yaml fue temporalmente modificado para el build${NC}"
    echo -e "${YELLOW}      Puedes restaurarlo con: mv pubspec.yaml.bak pubspec.yaml${NC}"
fi

echo ""
echo -e "${GREEN}✨ Script completado exitosamente!${NC}"