#!/bin/bash

# ============================================
# ALMA - Monitor de Despliegue
# Script para verificar el estado del despliegue
# ============================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables
REPO_URL=$(git config --get remote.origin.url)
REPO_NAME="alma"
REPO_OWNER=$(echo $REPO_URL | sed 's/.*github.com[:/]\(.*\)\/.*/\1/')
SITE_URL="https://${REPO_OWNER}.github.io/${REPO_NAME}/"
API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}"

# Banner
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              ALMA - Monitor de Despliegue               ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Funciones
check_mark() {
    echo -e "${GREEN}✓${NC}"
}

x_mark() {
    echo -e "${RED}✗${NC}"
}

loading() {
    echo -ne "${YELLOW}⋯${NC}"
}

# 1. Verificar último workflow
echo -e "${BLUE}▶ Verificando último despliegue...${NC}"
echo ""

if command -v gh &> /dev/null; then
    echo "Últimas ejecuciones del workflow:"
    gh run list --workflow=flutter-web-deploy.yml --limit 3 2>/dev/null || {
        echo -e "${YELLOW}No se pudo obtener información del workflow${NC}"
        echo "Verifica manualmente en: https://github.com/${REPO_OWNER}/${REPO_NAME}/actions"
    }
else
    echo -e "${YELLOW}GitHub CLI no instalado.${NC}"
    echo "Verifica el estado en: https://github.com/${REPO_OWNER}/${REPO_NAME}/actions"
fi

echo ""

# 2. Verificar branch gh-pages
echo -e "${BLUE}▶ Verificando rama gh-pages...${NC}"
echo -n "  Existencia de gh-pages: "
loading

if git ls-remote --heads origin gh-pages | grep -q gh-pages; then
    check_mark
    
    # Obtener último commit
    LAST_COMMIT=$(git ls-remote origin gh-pages | cut -f1 | cut -c1-7)
    echo "  Último commit: ${LAST_COMMIT}"
    
    # Verificar edad del commit (requiere gh o curl)
    if command -v curl &> /dev/null; then
        COMMIT_INFO=$(curl -s "${API_URL}/commits/${LAST_COMMIT}" 2>/dev/null)
        if [ $? -eq 0 ]; then
            COMMIT_DATE=$(echo $COMMIT_INFO | grep -o '"date":"[^"]*' | head -1 | cut -d'"' -f4)
            if [ ! -z "$COMMIT_DATE" ]; then
                echo "  Fecha: ${COMMIT_DATE}"
            fi
        fi
    fi
else
    x_mark
    echo -e "${RED}  La rama gh-pages no existe. El primer despliegue la creará.${NC}"
fi

echo ""

# 3. Verificar disponibilidad del sitio
echo -e "${BLUE}▶ Verificando sitio web...${NC}"
echo "  URL: ${SITE_URL}"
echo -n "  Estado HTTP: "
loading

# Hacer petición HTTP
if command -v curl &> /dev/null; then
    HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" -L "${SITE_URL}" 2>/dev/null)
    
    case $HTTP_STATUS in
        200)
            check_mark
            echo -e "  ${GREEN}Sitio disponible y funcionando${NC}"
            ;;
        404)
            x_mark
            echo -e "  ${RED}Error 404 - Sitio no encontrado${NC}"
            echo -e "  ${YELLOW}Posibles causas:${NC}"
            echo "    • GitHub Pages no está habilitado"
            echo "    • El despliegue aún no ha terminado"
            echo "    • La rama gh-pages no tiene contenido"
            ;;
        301|302)
            echo -e "${YELLOW}${HTTP_STATUS} - Redirección${NC}"
            ;;
        *)
            echo -e "${YELLOW}${HTTP_STATUS}${NC}"
            ;;
    esac
    
    # Verificar tamaño de la respuesta
    if [ "$HTTP_STATUS" == "200" ]; then
        SIZE=$(curl -sI "${SITE_URL}" | grep -i content-length | awk '{print $2}' | tr -d '\r')
        if [ ! -z "$SIZE" ] && [ "$SIZE" -gt 0 ]; then
            SIZE_KB=$((SIZE / 1024))
            echo "  Tamaño de respuesta: ~${SIZE_KB} KB"
        fi
    fi
else
    echo -e "${YELLOW}curl no disponible${NC}"
    echo "  Verifica manualmente en: ${SITE_URL}"
fi

echo ""

# 4. Verificar configuración de GitHub Pages
echo -e "${BLUE}▶ Configuración de GitHub Pages...${NC}"

if command -v gh &> /dev/null; then
    PAGES_INFO=$(gh api "repos/${REPO_OWNER}/${REPO_NAME}/pages" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}GitHub Pages está habilitado${NC}"
        
        # Extraer información
        PAGES_URL=$(echo $PAGES_INFO | grep -o '"html_url":"[^"]*' | cut -d'"' -f4)
        PAGES_STATUS=$(echo $PAGES_INFO | grep -o '"status":"[^"]*' | cut -d'"' -f4)
        PAGES_BRANCH=$(echo $PAGES_INFO | grep -o '"branch":"[^"]*' | cut -d'"' -f4)
        
        [ ! -z "$PAGES_URL" ] && echo "  URL configurada: $PAGES_URL"
        [ ! -z "$PAGES_STATUS" ] && echo "  Estado: $PAGES_STATUS"
        [ ! -z "$PAGES_BRANCH" ] && echo "  Rama: $PAGES_BRANCH"
    else
        echo -e "  ${YELLOW}No se pudo verificar el estado de GitHub Pages${NC}"
        echo "  Configura manualmente en: https://github.com/${REPO_OWNER}/${REPO_NAME}/settings/pages"
    fi
else
    echo -e "  ${YELLOW}Verifica en: https://github.com/${REPO_OWNER}/${REPO_NAME}/settings/pages${NC}"
fi

echo ""

# 5. Test de funcionalidad básica
echo -e "${BLUE}▶ Test de funcionalidad...${NC}"

if [ "$HTTP_STATUS" == "200" ]; then
    echo -n "  Verificando Flutter app: "
    loading
    
    # Buscar indicadores de Flutter
    if command -v curl &> /dev/null; then
        CONTENT=$(curl -s -L "${SITE_URL}" 2>/dev/null | head -n 200)
        
        if echo "$CONTENT" | grep -q "flutter"; then
            check_mark
            echo -e "  ${GREEN}Aplicación Flutter detectada${NC}"
        else
            echo -e "${YELLOW}?${NC}"
            echo -e "  ${YELLOW}No se pudo confirmar si es una app Flutter${NC}"
        fi
        
        # Verificar archivos críticos
        echo ""
        echo "  Verificando archivos críticos:"
        
        FILES_TO_CHECK=("main.dart.js" "flutter_service_worker.js" "manifest.json" "index.html")
        for FILE in "${FILES_TO_CHECK[@]}"; do
            echo -n "    • $FILE: "
            FILE_STATUS=$(curl -o /dev/null -s -w "%{http_code}" -L "${SITE_URL}${FILE}" 2>/dev/null)
            if [ "$FILE_STATUS" == "200" ]; then
                check_mark
            else
                x_mark
            fi
        done
    fi
else
    echo -e "  ${YELLOW}No se puede verificar - sitio no accesible${NC}"
fi

echo ""

# 6. Resumen y recomendaciones
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}                      RESUMEN                           ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

if [ "$HTTP_STATUS" == "200" ]; then
    echo -e "${GREEN}✅ El sitio está desplegado y funcionando${NC}"
    echo ""
    echo "Accede a tu aplicación en:"
    echo -e "${BLUE}${SITE_URL}${NC}"
else
    echo -e "${YELLOW}⚠️ El sitio no está disponible aún${NC}"
    echo ""
    echo "Acciones recomendadas:"
    echo "1. Verifica que hayas hecho push a la rama main"
    echo "2. Revisa el estado del workflow en GitHub Actions"
    echo "3. Asegúrate de que GitHub Pages esté habilitado"
    echo "4. Espera 5-10 minutos si es el primer despliegue"
    echo ""
    echo "Enlaces útiles:"
    echo "• Actions: https://github.com/${REPO_OWNER}/${REPO_NAME}/actions"
    echo "• Settings: https://github.com/${REPO_OWNER}/${REPO_NAME}/settings/pages"
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"

# Ofrecer monitoreo continuo
echo ""
read -p "¿Deseas monitorear continuamente? (actualizará cada 30s) [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Monitoreando... Presiona Ctrl+C para detener${NC}"
    while true; do
        sleep 30
        clear
        $0  # Ejecutar el script nuevamente
    done
fi