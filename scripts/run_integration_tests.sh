#!/bin/bash

# Script para ejecutar tests de integración de ALMA
# Uso: ./scripts/run_integration_tests.sh [platform] [test_file]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}ALMA Integration Tests Runner${NC}"
    echo ""
    echo "Uso: $0 [PLATFORM] [TEST_FILE]"
    echo ""
    echo "PLATFORMS disponibles:"
    echo "  web       - Ejecutar en navegador web"
    echo "  android   - Ejecutar en dispositivo/emulador Android"
    echo "  linux     - Ejecutar en desktop Linux"
    echo "  all       - Ejecutar en todas las plataformas disponibles"
    echo ""
    echo "TEST_FILE (opcional):"
    echo "  app_test.dart                                - Test principal de la aplicación"
    echo ""
    echo "Ejemplos:"
    echo "  $0 web                                       # Todos los tests en web"
    echo "  $0 android app_test.dart                    # Test principal en Android"
    echo "  $0 linux app_test.dart                      # Test principal en Linux"
}

# Función para verificar dependencias
check_dependencies() {
    echo -e "${YELLOW}Verificando dependencias...${NC}"
    
    if ! flutter doctor > /dev/null 2>&1; then
        echo -e "${RED}Error: Flutter no está instalado o no está en PATH${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Flutter encontrado${NC}"
    flutter pub get > /dev/null
    echo -e "${GREEN}✓ Dependencias instaladas${NC}"
}

# Función para ejecutar tests en web
run_web_tests() {
    local test_file="$1"
    echo -e "${BLUE}Ejecutando tests de integración en WEB...${NC}"
    
    # Habilitar web si no está habilitado
    flutter config --enable-web > /dev/null
    
    if [ -n "$test_file" ]; then
        echo -e "${YELLOW}Ejecutando: integration_test/$test_file${NC}"
        flutter drive \
            --driver=test_driver/integration_test.dart \
            --target=integration_test/$test_file \
            -d web-server \
            --web-port=7357 \
            --web-hostname=localhost
    else
        echo -e "${YELLOW}Ejecutando todos los tests de integración...${NC}"
        # Ejecutar tests principales
        local tests=(
            "app_test.dart"
        )
        
        for test in "${tests[@]}"; do
            if [ -f "integration_test/$test" ]; then
                echo -e "${BLUE}→ Ejecutando: $test${NC}"
                flutter drive \
                    --driver=test_driver/integration_test.dart \
                    --target=integration_test/$test \
                    -d web-server \
                    --web-port=7357 \
                    --web-hostname=localhost || echo -e "${RED}✗ Falló: $test${NC}"
            fi
        done
    fi
}

# Función para ejecutar tests en Android
run_android_tests() {
    local test_file="$1"
    echo -e "${BLUE}Ejecutando tests de integración en ANDROID...${NC}"
    
    # Verificar que hay dispositivos Android disponibles
    if ! flutter devices | grep -q "android"; then
        echo -e "${RED}Error: No se encontraron dispositivos Android conectados${NC}"
        echo -e "${YELLOW}Asegúrate de tener un emulador ejecutándose o un dispositivo conectado${NC}"
        exit 1
    fi
    
    if [ -n "$test_file" ]; then
        echo -e "${YELLOW}Ejecutando: integration_test/$test_file${NC}"
        flutter drive \
            --driver=test_driver/integration_test.dart \
            --target=integration_test/$test_file \
            -d android
    else
        echo -e "${YELLOW}Ejecutando tests principales en Android...${NC}"
        local tests=(
            "app_test.dart"
        )
        
        for test in "${tests[@]}"; do
            if [ -f "integration_test/$test" ]; then
                echo -e "${BLUE}→ Ejecutando: $test${NC}"
                flutter drive \
                    --driver=test_driver/integration_test.dart \
                    --target=integration_test/$test \
                    -d android || echo -e "${RED}✗ Falló: $test${NC}"
            fi
        done
    fi
}

# Función para ejecutar tests en Linux
run_linux_tests() {
    local test_file="$1"
    echo -e "${BLUE}Ejecutando tests de integración en LINUX...${NC}"
    
    # Habilitar desktop Linux si no está habilitado
    flutter config --enable-linux-desktop > /dev/null
    
    if [ -n "$test_file" ]; then
        echo -e "${YELLOW}Ejecutando: integration_test/$test_file${NC}"
        flutter drive \
            --driver=test_driver/integration_test.dart \
            --target=integration_test/$test_file \
            -d linux
    else
        echo -e "${YELLOW}Ejecutando tests principales en Linux...${NC}"
        local tests=(
            "app_test.dart"
        )
        
        for test in "${tests[@]}"; do
            if [ -f "integration_test/$test" ]; then
                echo -e "${BLUE}→ Ejecutando: $test${NC}"
                flutter drive \
                    --driver=test_driver/integration_test.dart \
                    --target=integration_test/$test \
                    -d linux || echo -e "${RED}✗ Falló: $test${NC}"
            fi
        done
    fi
}


# Función principal
main() {
    local platform="$1"
    local test_file="$2"
    
    # Mostrar ayuda si no hay argumentos o se pide ayuda
    if [ "$#" -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi
    
    # Cambiar al directorio del proyecto
    cd "$(dirname "$0")/.."
    
    # Verificar dependencias
    check_dependencies
    
    echo -e "${GREEN}🚀 Iniciando tests de integración de ALMA${NC}"
    echo -e "${BLUE}Plataforma: $platform${NC}"
    if [ -n "$test_file" ]; then
        echo -e "${BLUE}Test específico: $test_file${NC}"
    fi
    echo ""
    
    case $platform in
        web)
            run_web_tests "$test_file"
            ;;
        android)
            run_android_tests "$test_file"
            ;;
        linux)
            run_linux_tests "$test_file"
            ;;
        all)
            echo -e "${BLUE}Ejecutando en todas las plataformas disponibles...${NC}"
            run_web_tests "$test_file"
            echo ""
            run_linux_tests "$test_file"
            echo ""
            # Solo ejecutar Android si hay dispositivos disponibles
            if flutter devices | grep -q "android"; then
                run_android_tests "$test_file"
            else
                echo -e "${YELLOW}⚠ Saltando Android: no hay dispositivos conectados${NC}"
            fi
            ;;
        *)
            echo -e "${RED}Error: Plataforma no reconocida: $platform${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}✅ Tests de integración completados${NC}"
}

# Ejecutar función principal con todos los argumentos
main "$@"