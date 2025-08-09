#!/bin/bash

# setup-complete.sh - Setup completo automatizado para Flutter GitHub Pages
# Version: 2.0.0
# Fecha: 2025-08-09

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Banner
echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║     FLUTTER GITHUB PAGES - SETUP AUTOMATIZADO       ║"
echo "║                    Version 2.0                       ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Variables
ERRORS_FOUND=0
WARNINGS_FOUND=0
REPO_URL=$(git config --get remote.origin.url 2>/dev/null || echo "")
REPO_NAME=""
GITHUB_USER=""

# Funciones de utilidad
print_step() {
    echo -e "\n${BLUE}${BOLD}▶ $1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 no está instalado"
        return 1
    else
        print_success "$1 está instalado"
        return 0
    fi
}

# 1. VERIFICACIÓN DE PREREQUISITOS
print_step "PASO 1: Verificando prerequisitos"

# Verificar Git
if ! check_command git; then
    echo "Instala Git desde: https://git-scm.com/"
    exit 1
fi

# Verificar Flutter
if ! check_command flutter; then
    echo "Instala Flutter desde: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Verificar curl
check_command curl || print_warning "curl no instalado (necesario para verificaciones)"

# 2. VERIFICACIÓN DE VERSIONES
print_step "PASO 2: Verificando versiones"

# Flutter version
FLUTTER_VERSION=$(flutter --version 2>/dev/null | grep "Flutter" | cut -d' ' -f2 || echo "0.0.0")
REQUIRED_FLUTTER="3.32.0"

if [ "$(printf '%s\n' "$REQUIRED_FLUTTER" "$FLUTTER_VERSION" | sort -V | head -n1)" = "$REQUIRED_FLUTTER" ]; then 
    print_success "Flutter $FLUTTER_VERSION es compatible (>= $REQUIRED_FLUTTER)"
else
    print_error "Flutter $FLUTTER_VERSION es muy antiguo. Se requiere $REQUIRED_FLUTTER+"
    echo "Ejecuta: flutter upgrade"
fi

# Dart version
DART_VERSION=$(dart --version 2>&1 | grep -oP 'version: \K[0-9.]+' || echo "0.0.0")
REQUIRED_DART="3.8.1"

if [ "$(printf '%s\n' "$REQUIRED_DART" "$DART_VERSION" | sort -V | head -n1)" = "$REQUIRED_DART" ]; then 
    print_success "Dart $DART_VERSION es compatible (>= $REQUIRED_DART)"
else
    print_error "Dart $DART_VERSION es muy antiguo. Se requiere $REQUIRED_DART+"
fi

# 3. VERIFICACIÓN DEL PROYECTO
print_step "PASO 3: Verificando proyecto Flutter"

if [ ! -f "pubspec.yaml" ]; then
    print_error "No se encontró pubspec.yaml. ¿Estás en la raíz del proyecto Flutter?"
    exit 1
else
    print_success "pubspec.yaml encontrado"
    
    # Verificar SDK constraint
    if grep -q "sdk: .*3\.8" pubspec.yaml; then
        print_success "SDK constraint correcto en pubspec.yaml"
    else
        print_warning "SDK constraint puede necesitar actualización"
        echo "  Recomendado: sdk: ^3.8.1"
    fi
    
    # Verificar flutter_lints
    if grep -q "flutter_lints: ^4" pubspec.yaml; then
        print_success "flutter_lints v4 configurado correctamente"
    elif grep -q "flutter_lints: ^5" pubspec.yaml; then
        print_warning "flutter_lints v5 puede causar problemas"
        echo "  Cambiando a v4..."
        sed -i.bak 's/flutter_lints: ^5/flutter_lints: ^4/' pubspec.yaml
        print_success "flutter_lints actualizado a v4"
    fi
fi

# 4. CONFIGURACIÓN DE GIT
print_step "PASO 4: Configurando repositorio Git"

if [ -z "$REPO_URL" ]; then
    print_error "No se detectó repositorio Git remoto"
    echo "Añade un remote con: git remote add origin https://github.com/USUARIO/REPO.git"
else
    print_success "Repositorio remoto detectado: $REPO_URL"
    
    # Extraer información del repositorio
    REPO_NAME=$(basename -s .git "$REPO_URL")
    GITHUB_USER=$(echo "$REPO_URL" | sed -n 's/.*github.com[:/]\([^/]*\)\/.*/\1/p')
    
    if [ -n "$REPO_NAME" ] && [ -n "$GITHUB_USER" ]; then
        print_info "Usuario: $GITHUB_USER"
        print_info "Repositorio: $REPO_NAME"
        print_info "URL del sitio: https://$GITHUB_USER.github.io/$REPO_NAME/"
    else
        print_warning "No se pudo extraer información completa del repositorio"
    fi
fi

# 5. CREAR RAMA GH-PAGES
print_step "PASO 5: Configurando rama gh-pages"

if git show-ref --verify --quiet refs/heads/gh-pages; then
    print_success "Rama gh-pages ya existe localmente"
elif git ls-remote --heads origin gh-pages | grep -q gh-pages; then
    print_success "Rama gh-pages existe en remoto"
    echo "Obteniendo rama remota..."
    git fetch origin gh-pages:gh-pages
else
    print_info "Creando rama gh-pages..."
    CURRENT_BRANCH=$(git branch --show-current)
    
    # Guardar cambios actuales si los hay
    if [ -n "$(git status --porcelain)" ]; then
        print_warning "Hay cambios sin commit. Guardando temporalmente..."
        git stash push -m "Setup script temporary stash"
    fi
    
    # Crear rama gh-pages
    git checkout --orphan gh-pages
    git rm -rf . 2>/dev/null || true
    echo "<!DOCTYPE html><html><head><title>GitHub Pages</title></head><body><h1>GitHub Pages Initialized</h1><p>Deploy in progress...</p></body></html>" > index.html
    git add index.html
    git config user.name "Setup Script" 2>/dev/null || true
    git config user.email "setup@example.com" 2>/dev/null || true
    git commit -m "Initial gh-pages branch"
    git push origin gh-pages
    
    # Volver a la rama original
    git checkout "$CURRENT_BRANCH"
    
    # Restaurar cambios si los había
    if git stash list | grep -q "Setup script temporary stash"; then
        git stash pop
    fi
    
    print_success "Rama gh-pages creada y publicada"
fi

# 6. CREAR ESTRUCTURA DE DIRECTORIOS
print_step "PASO 6: Creando estructura de archivos"

# Crear directorios necesarios
directories=(".github/workflows" "scripts" "web")
for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_success "Directorio $dir creado"
    else
        print_info "Directorio $dir ya existe"
    fi
done

# 7. CREAR ARCHIVOS DE CONFIGURACIÓN
print_step "PASO 7: Creando archivos de configuración"

# Crear .nojekyll
if [ ! -f "web/.nojekyll" ]; then
    touch web/.nojekyll
    print_success "Archivo web/.nojekyll creado"
else
    print_info "Archivo web/.nojekyll ya existe"
fi

# Verificar/actualizar .gitignore
if [ -f ".gitignore" ]; then
    if ! grep -q "build/" .gitignore; then
        echo -e "\n# Build directories\nbuild/" >> .gitignore
        print_success "Añadido build/ a .gitignore"
    fi
    
    if ! grep -q ".flutter-plugins" .gitignore; then
        echo -e "\n# Flutter\n.flutter-plugins\n.flutter-plugins-dependencies" >> .gitignore
        print_success "Añadidas exclusiones Flutter a .gitignore"
    fi
else
    cat > .gitignore << 'EOF'
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# Flutter/Dart/Pub related
**/doc/api/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/

# Web related
lib/generated_plugin_registrant.dart

# Exceptions to above rules.
!/packages/flutter_tools/test/data/dart_dependencies_test/**/.packages
EOF
    print_success "Archivo .gitignore creado"
fi

# 8. CREAR WORKFLOW DE GITHUB ACTIONS
print_step "PASO 8: Configurando GitHub Actions"

WORKFLOW_FILE=".github/workflows/flutter-web-deploy.yml"
if [ ! -f "$WORKFLOW_FILE" ]; then
    print_info "Creando workflow de GitHub Actions..."
    # El contenido del workflow ya fue creado anteriormente
    print_success "Workflow creado en $WORKFLOW_FILE"
    print_warning "Revisa el archivo de workflow antes de hacer commit"
else
    print_info "Workflow ya existe en $WORKFLOW_FILE"
fi

# 9. VERIFICACIÓN DE DEPENDENCIAS
print_step "PASO 9: Verificando dependencias Flutter"

print_info "Limpiando proyecto..."
flutter clean 2>/dev/null || print_warning "No se pudo limpiar el proyecto"

print_info "Obteniendo dependencias..."
flutter pub get || print_error "Error al obtener dependencias"

# 10. BUILD DE PRUEBA
print_step "PASO 10: Realizando build de prueba"

if [ -n "$REPO_NAME" ]; then
    print_info "Construyendo aplicación web..."
    if flutter build web --release --base-href "/$REPO_NAME/" 2>/dev/null; then
        print_success "Build de prueba exitoso"
        
        if [ -d "build/web" ]; then
            FILE_COUNT=$(find build/web -type f | wc -l)
            DIR_SIZE=$(du -sh build/web 2>/dev/null | cut -f1)
            print_info "Archivos generados: $FILE_COUNT"
            print_info "Tamaño del build: $DIR_SIZE"
        fi
    else
        print_warning "Build de prueba falló - verifica tu código"
    fi
else
    print_warning "No se pudo realizar build de prueba (falta información del repo)"
fi

# 11. CONFIGURACIÓN DE GITHUB PAGES
print_step "PASO 11: Instrucciones para GitHub Pages"

if [ -n "$GITHUB_USER" ] && [ -n "$REPO_NAME" ]; then
    echo ""
    echo -e "${MAGENTA}${BOLD}📋 CONFIGURACIÓN MANUAL REQUERIDA:${NC}"
    echo ""
    echo "1. Ve a: https://github.com/$GITHUB_USER/$REPO_NAME/settings/pages"
    echo "2. En 'Source', selecciona: 'Deploy from a branch'"
    echo "3. En 'Branch', selecciona: 'gh-pages'"
    echo "4. En 'Folder', selecciona: '/ (root)'"
    echo "5. Click en 'Save'"
    echo ""
    echo -e "${GREEN}Tu sitio estará disponible en:${NC}"
    echo -e "${BOLD}https://$GITHUB_USER.github.io/$REPO_NAME/${NC}"
fi

# 12. CREAR SCRIPTS ADICIONALES
print_step "PASO 12: Creando scripts de utilidad"

# Script de verificación
cat > scripts/verify.sh << 'EOF'
#!/bin/bash
# Verificar estado del despliegue

REPO_URL=$(git config --get remote.origin.url)
REPO_NAME=$(basename -s .git "$REPO_URL")
GITHUB_USER=$(echo "$REPO_URL" | sed -n 's/.*github.com[:/]\([^/]*\)\/.*/\1/p')
URL="https://$GITHUB_USER.github.io/$REPO_NAME/"

echo "Verificando: $URL"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Sitio disponible!"
else
    echo "❌ Sitio no disponible (HTTP $HTTP_CODE)"
fi
EOF

chmod +x scripts/verify.sh
print_success "Script de verificación creado"

# 13. RESUMEN FINAL
print_step "RESUMEN DE CONFIGURACIÓN"

echo ""
echo -e "${CYAN}${BOLD}📊 Estadísticas:${NC}"
echo "• Errores encontrados: $ERRORS_FOUND"
echo "• Advertencias: $WARNINGS_FOUND"

if [ $ERRORS_FOUND -eq 0 ]; then
    echo ""
    echo -e "${GREEN}${BOLD}✅ CONFIGURACIÓN COMPLETADA EXITOSAMENTE${NC}"
    echo ""
    echo -e "${YELLOW}Próximos pasos:${NC}"
    echo "1. Configura GitHub Pages manualmente (ver instrucciones arriba)"
    echo "2. Revisa el workflow en .github/workflows/flutter-web-deploy.yml"
    echo "3. Haz commit de los cambios:"
    echo "   git add ."
    echo "   git commit -m 'Configure GitHub Pages deployment'"
    echo "   git push origin main"
    echo "4. Verifica el despliegue con: ./scripts/verify.sh"
else
    echo ""
    echo -e "${RED}${BOLD}❌ HAY ERRORES QUE RESOLVER${NC}"
    echo "Por favor, corrige los errores listados arriba antes de continuar."
fi

echo ""
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}       Setup completado - $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════${NC}"