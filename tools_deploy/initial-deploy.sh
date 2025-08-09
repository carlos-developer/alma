#!/bin/bash

# ============================================
# ALMA - Script de Despliegue Inicial
# Prepara y verifica todo para el primer despliegue
# ============================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Banner
clear
echo -e "${MAGENTA}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║         ALMA - CONFIGURACIÓN INICIAL DE DESPLIEGUE        ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Funciones de utilidad
print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "  ${RED}✗${NC} $1"
}

print_info() {
    echo -e "  ${BLUE}ℹ${NC} $1"
}

# Variables del proyecto
REPO_URL=$(git config --get remote.origin.url)
REPO_NAME="alma"  # Nombre fijo del proyecto
REPO_OWNER=$(echo $REPO_URL | sed 's/.*github.com[:/]\(.*\)\/.*/\1/')
CURRENT_BRANCH=$(git branch --show-current)

# ============================================
# PASO 1: Verificación del entorno
# ============================================
print_step "PASO 1: Verificando entorno de desarrollo"

# Verificar Flutter
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    print_success "Flutter instalado: $FLUTTER_VERSION"
else
    print_error "Flutter no está instalado"
    exit 1
fi

# Verificar Flutter Web
if flutter config | grep -q "enable-web: true"; then
    print_success "Flutter Web habilitado"
else
    print_warning "Flutter Web no habilitado, activando..."
    flutter config --enable-web
    print_success "Flutter Web activado"
fi

# Verificar Git
if [ -d .git ]; then
    print_success "Repositorio Git detectado"
    print_info "URL: $REPO_URL"
    print_info "Owner: $REPO_OWNER"
    print_info "Rama actual: $CURRENT_BRANCH"
else
    print_error "No es un repositorio Git"
    exit 1
fi

# ============================================
# PASO 2: Verificación de archivos necesarios
# ============================================
echo ""
print_step "PASO 2: Verificando archivos de configuración"

# Verificar workflow
if [ -f ".github/workflows/flutter-web-deploy.yml" ]; then
    print_success "Workflow de GitHub Actions encontrado"
else
    print_error "Workflow no encontrado en .github/workflows/"
    exit 1
fi

# Verificar .nojekyll
if [ ! -f "web/.nojekyll" ]; then
    print_warning ".nojekyll no existe, creando..."
    touch web/.nojekyll
    print_success ".nojekyll creado"
else
    print_success ".nojekyll existe"
fi

# Verificar 404.html
if [ ! -f "web/404.html" ]; then
    print_warning "404.html no existe, será creado durante el build"
else
    print_success "404.html existe"
fi

# ============================================
# PASO 3: Verificación de dependencias
# ============================================
echo ""
print_step "PASO 3: Verificando dependencias del proyecto"

# Verificar flutter_lints
if grep -q "flutter_lints: \^5\." pubspec.yaml; then
    print_warning "flutter_lints v5 detectado - puede causar problemas de compatibilidad"
    print_info "El workflow ajustará esto automáticamente"
else
    print_success "Versión de flutter_lints compatible"
fi

# Instalar dependencias
print_info "Instalando dependencias..."
flutter pub get > /dev/null 2>&1
print_success "Dependencias instaladas"

# ============================================
# PASO 4: Test de build local
# ============================================
echo ""
print_step "PASO 4: Probando build local"

read -p "¿Deseas hacer un build de prueba local? (recomendado) [Y/n]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    print_info "Ejecutando build de prueba..."
    
    # Ejecutar build
    if flutter build web --release --base-href /$REPO_NAME/ > /dev/null 2>&1; then
        print_success "Build local exitoso"
        BUILD_SIZE=$(du -sh build/web/ | cut -f1)
        print_info "Tamaño del build: $BUILD_SIZE"
        
        # Ofrecer servidor local
        read -p "¿Deseas probar el build localmente? [Y/n]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            print_info "Iniciando servidor local..."
            print_warning "Abre http://localhost:8080 en tu navegador"
            print_warning "Presiona Ctrl+C para detener"
            cd build/web && python3 -m http.server 8080
            cd ../..
        fi
    else
        print_error "Error en el build local"
        print_warning "Revisa los errores antes de continuar"
    fi
else
    print_info "Build de prueba omitido"
fi

# ============================================
# PASO 5: Verificación del estado de Git
# ============================================
echo ""
print_step "PASO 5: Verificando estado de Git"

# Verificar cambios sin commitear
if [[ -n $(git status -s) ]]; then
    print_warning "Hay cambios sin commitear:"
    git status -s
    echo ""
    read -p "¿Deseas commitear estos cambios ahora? [Y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        git add .
        read -p "Mensaje del commit: " COMMIT_MSG
        git commit -m "$COMMIT_MSG"
        print_success "Cambios commiteados"
    fi
else
    print_success "No hay cambios pendientes"
fi

# ============================================
# PASO 6: Configuración de GitHub Pages
# ============================================
echo ""
print_step "PASO 6: Instrucciones para GitHub Pages"

echo -e "${YELLOW}┌─────────────────────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}│          CONFIGURACIÓN MANUAL EN GITHUB                  │${NC}"
echo -e "${YELLOW}└─────────────────────────────────────────────────────────┘${NC}"
echo ""
echo "  1. Ve a: https://github.com/$REPO_OWNER/$REPO_NAME/settings/pages"
echo ""
echo "  2. En 'Source', selecciona:"
echo "     • Deploy from a branch"
echo ""
echo "  3. En 'Branch', selecciona:"
echo "     • gh-pages"
echo "     • / (root)"
echo ""
echo "  4. Haz clic en 'Save'"
echo ""
echo -e "${YELLOW}┌─────────────────────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}│       IMPORTANTE: Realiza esto DESPUÉS del primer push  │${NC}"
echo -e "${YELLOW}└─────────────────────────────────────────────────────────┘${NC}"

# ============================================
# PASO 7: Instrucciones finales
# ============================================
echo ""
print_step "PASO 7: Próximos pasos para desplegar"

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}        TODO LISTO PARA EL DESPLIEGUE                   ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""

if [ "$CURRENT_BRANCH" == "develop" ]; then
    echo "Estás en la rama 'develop'. Ejecuta estos comandos:"
    echo ""
    echo -e "${YELLOW}# 1. Cambiar a main y actualizar${NC}"
    echo "   git checkout main"
    echo "   git pull origin main"
    echo ""
    echo -e "${YELLOW}# 2. Mergear develop en main${NC}"
    echo "   git merge develop"
    echo ""
    echo -e "${YELLOW}# 3. Push para activar el despliegue${NC}"
    echo "   git push origin main"
elif [ "$CURRENT_BRANCH" == "main" ]; then
    echo "Ya estás en main. Solo necesitas hacer push:"
    echo ""
    echo -e "${YELLOW}# Push para activar el despliegue${NC}"
    echo "   git push origin main"
else
    echo "Estás en la rama '$CURRENT_BRANCH'."
    echo "Primero debes cambiar a main o develop."
fi

echo ""
echo -e "${BLUE}📌 URLs importantes:${NC}"
echo ""
echo "  • Sitio web: ${GREEN}https://$REPO_OWNER.github.io/$REPO_NAME/${NC}"
echo "  • Actions: https://github.com/$REPO_OWNER/$REPO_NAME/actions"
echo "  • Settings: https://github.com/$REPO_OWNER/$REPO_NAME/settings/pages"
echo ""
echo -e "${YELLOW}⏱️  Notas:${NC}"
echo "  • El primer despliegue puede tardar 5-10 minutos"
echo "  • Los siguientes despliegues tardan 2-3 minutos"
echo "  • Verifica el estado en la pestaña Actions de GitHub"
echo ""
echo -e "${GREEN}¡Buena suerte con tu despliegue!${NC}"
echo ""