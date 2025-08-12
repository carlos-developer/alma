#!/bin/bash

# Script específico para ejecutar tests de integración en dispositivo físico Android
# Uso: ./scripts/run_integration_android_device.sh [test_file]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}ALMA Integration Tests - Android Physical Device${NC}"
echo ""

# Cambiar al directorio del proyecto
cd "$(dirname "$0")/.."

# Verificar que Flutter esté disponible
if ! flutter doctor > /dev/null 2>&1; then
    echo -e "${RED}Error: Flutter no está instalado o no está en PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Flutter encontrado${NC}"

# Obtener dependencias
echo -e "${YELLOW}Instalando dependencias...${NC}"
flutter pub get > /dev/null
echo -e "${GREEN}✓ Dependencias instaladas${NC}"

# Verificar que hay dispositivos Android conectados
echo -e "${YELLOW}Verificando dispositivos Android...${NC}"
if ! flutter devices | grep -q "android"; then
    echo -e "${RED}Error: No se encontraron dispositivos Android conectados${NC}"
    echo -e "${YELLOW}Pasos para solucionar:${NC}"
    echo "1. Conecta tu dispositivo Android via USB"
    echo "2. Habilita 'Depuración USB' en opciones de desarrollador"
    echo "3. Acepta la ventana de autorización en tu dispositivo"
    echo "4. Ejecuta 'flutter devices' para verificar"
    exit 1
fi

# Mostrar dispositivos disponibles
echo -e "${GREEN}✓ Dispositivos Android encontrados:${NC}"
flutter devices | grep "android" | head -5

echo ""

# Determinar qué test ejecutar
TEST_FILE="${1:-app_integration_test.dart}"
echo -e "${BLUE}Ejecutando: integration_test/$TEST_FILE${NC}"
echo -e "${YELLOW}Nota: Este test puede tardar varios minutos en dispositivo físico...${NC}"
echo ""

# Ejecutar el test específico usando flutter test (no flutter drive)
# flutter test es más estable para integration tests en dispositivos físicos
echo -e "${BLUE}Iniciando test de integración...${NC}"

if flutter test "integration_test/$TEST_FILE" --timeout=10m; then
    echo ""
    echo -e "${GREEN}✅ Test de integración completado exitosamente${NC}"
    echo ""
    echo -e "${BLUE}Resumen de ejecución:${NC}"
    echo "- Dispositivo: Android (físico)"
    echo "- Test: $TEST_FILE"
    echo "- Estado: EXITOSO"
else
    echo ""
    echo -e "${RED}❌ Test de integración falló${NC}"
    echo ""
    echo -e "${YELLOW}Consejos para debugging:${NC}"
    echo "1. Verifica que el dispositivo tenga suficiente batería"
    echo "2. Asegúrate de que la app se puede instalar normalmente"
    echo "3. Ejecuta 'flutter run' primero para verificar conectividad"
    echo "4. Revisa los logs de error mostrados arriba"
    exit 1
fi