#!/bin/bash

# Setup script para MCP GitHub en el proyecto ALMA
# Este script configura el servidor MCP de GitHub para integrarse con Claude Code

echo "🚀 Configurando MCP GitHub para el proyecto ALMA"
echo "================================================"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar comandos
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Verificar Node.js
echo -e "\n${YELLOW}1. Verificando Node.js...${NC}"
if command_exists node; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓ Node.js instalado: $NODE_VERSION${NC}"
else
    echo -e "${RED}✗ Node.js no está instalado${NC}"
    echo "Por favor instala Node.js desde: https://nodejs.org/"
    exit 1
fi

# 2. Verificar npm
echo -e "\n${YELLOW}2. Verificando npm...${NC}"
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓ npm instalado: $NPM_VERSION${NC}"
else
    echo -e "${RED}✗ npm no está instalado${NC}"
    exit 1
fi

# 3. Instalar servidor MCP de GitHub
echo -e "\n${YELLOW}3. Instalando servidor MCP de GitHub...${NC}"
npm install -g @modelcontextprotocol/server-github

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Servidor MCP de GitHub instalado correctamente${NC}"
else
    echo -e "${RED}✗ Error al instalar el servidor MCP${NC}"
    echo "Intentando con npx..."
fi

# 4. Verificar archivo .env.mcp
echo -e "\n${YELLOW}4. Configurando token de GitHub...${NC}"
if [ ! -f ".env.mcp" ]; then
    echo -e "${RED}✗ Archivo .env.mcp no encontrado${NC}"
    echo "Creando archivo .env.mcp..."
    cp .env.mcp.example .env.mcp 2>/dev/null || touch .env.mcp
fi

# 5. Verificar si el token está configurado
if grep -q "tu_github_personal_access_token_aqui" .env.mcp; then
    echo -e "${YELLOW}⚠️  Necesitas configurar tu GitHub Personal Access Token${NC}"
    echo ""
    echo "Pasos para obtener tu token:"
    echo "1. Ve a: https://github.com/settings/tokens"
    echo "2. Click en 'Generate new token (classic)'"
    echo "3. Selecciona los siguientes permisos:"
    echo "   - repo (acceso completo)"
    echo "   - workflow (para GitHub Actions)"
    echo "   - read:org (para repos de organización)"
    echo "4. Copia el token y pégalo en .env.mcp"
    echo ""
    read -p "¿Quieres configurar el token ahora? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        read -p "Pega tu GitHub Personal Access Token: " GITHUB_TOKEN
        sed -i "s/tu_github_personal_access_token_aqui/$GITHUB_TOKEN/" .env.mcp
        echo -e "${GREEN}✓ Token configurado${NC}"
    fi
else
    echo -e "${GREEN}✓ Token de GitHub ya configurado${NC}"
fi

# 6. Instalar GitHub CLI (opcional pero recomendado)
echo -e "\n${YELLOW}5. Verificando GitHub CLI...${NC}"
if command_exists gh; then
    GH_VERSION=$(gh --version | head -n1)
    echo -e "${GREEN}✓ GitHub CLI instalado: $GH_VERSION${NC}"
    
    # Verificar autenticación
    if gh auth status >/dev/null 2>&1; then
        echo -e "${GREEN}✓ GitHub CLI autenticado${NC}"
    else
        echo -e "${YELLOW}⚠️  GitHub CLI no está autenticado${NC}"
        echo "Ejecuta: gh auth login"
    fi
else
    echo -e "${YELLOW}⚠️  GitHub CLI no está instalado${NC}"
    echo "Instalar con: sudo apt install gh (Ubuntu/Debian)"
    echo "O descarga desde: https://cli.github.com/"
fi

# 7. Crear archivo de ejemplo si no existe
echo -e "\n${YELLOW}6. Creando archivo de ejemplo...${NC}"
if [ ! -f ".env.mcp.example" ]; then
    cat > .env.mcp.example << 'EOF'
# MCP GitHub Configuration Example
# Copy this file to .env.mcp and configure your token

GITHUB_TOKEN=your_github_personal_access_token_here
GITHUB_OWNER=carlos-developer
GITHUB_REPO=alma
GITHUB_DEFAULT_BRANCH=main
EOF
    echo -e "${GREEN}✓ Archivo .env.mcp.example creado${NC}"
fi

# 8. Verificar configuración MCP
echo -e "\n${YELLOW}7. Verificando configuración MCP...${NC}"
if [ -f ".claude/mcp_config.json" ]; then
    echo -e "${GREEN}✓ Archivo de configuración MCP encontrado${NC}"
else
    echo -e "${RED}✗ Archivo de configuración MCP no encontrado${NC}"
fi

# 9. Test de conexión
echo -e "\n${YELLOW}8. Probando conexión con GitHub...${NC}"
if [ -f ".env.mcp" ] && ! grep -q "tu_github_personal_access_token_aqui" .env.mcp; then
    # Cargar variables de entorno
    export $(grep -v '^#' .env.mcp | xargs)
    
    # Probar conexión con API de GitHub
    RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)
    
    if echo "$RESPONSE" | grep -q "login"; then
        USERNAME=$(echo "$RESPONSE" | grep -o '"login":"[^"]*' | sed 's/"login":"//')
        echo -e "${GREEN}✓ Conexión exitosa con GitHub como: $USERNAME${NC}"
    else
        echo -e "${RED}✗ No se pudo conectar con GitHub. Verifica tu token.${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Configura tu token antes de probar la conexión${NC}"
fi

echo -e "\n${GREEN}================================================${NC}"
echo -e "${GREEN}Configuración completada${NC}"
echo ""
echo "Próximos pasos:"
echo "1. Asegúrate de configurar tu token en .env.mcp"
echo "2. Reinicia Claude Code para cargar la configuración MCP"
echo "3. Usa los comandos MCP de GitHub en Claude Code:"
echo "   - 'lista mis repositorios de GitHub'"
echo "   - 'crea un issue en GitHub'"
echo "   - 'muestra los PRs abiertos'"
echo ""
echo "Para más información, consulta .claude/README.md"