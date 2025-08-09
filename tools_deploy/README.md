# 🚀 Tools Deploy - Herramientas de Despliegue para ALMA

Esta carpeta contiene todas las herramientas, scripts y documentación necesarios para realizar el despliegue de la aplicación ALMA en GitHub Pages. Aquí encontrarás todo lo necesario para publicar y mantener la versión web de la aplicación.

## 📁 Estructura del Directorio

```
tools_deploy/
├── 📄 Documentación
│   ├── AUTOMATED_DEPLOYMENT_TEMPLATE.md
│   ├── DEPLOYMENT_SUCCESS_REPORT.md
│   └── QUICK_START_DEPLOYMENT.md
├── 🔧 Scripts de Bash
│   ├── deploy-to-pages.sh
│   ├── initial-deploy.sh
│   ├── monitor-deployment.sh
│   └── quick-deploy.sh
└── ⚙️ GitHub Actions Workflows
    ├── deploy_web.yml
    └── flutter-web-deploy.yml
```

## 📄 Documentación

### AUTOMATED_DEPLOYMENT_TEMPLATE.md
**Propósito:** Plantilla completa para automatizar el proceso de despliegue en GitHub Pages.

**Contenido:**
- Configuración inicial del repositorio
- Estructura de archivos necesarios
- Scripts de automatización detallados
- Configuración de GitHub Actions
- Solución de problemas comunes
- Checklist de verificación post-despliegue

**Cuándo usar:** Cuando necesites configurar un nuevo proceso de despliegue desde cero o revisar la configuración actual.

### DEPLOYMENT_SUCCESS_REPORT.md
**Propósito:** Reporte detallado de un despliegue exitoso con métricas y resultados.

**Contenido:**
- Resumen ejecutivo del despliegue
- Métricas de rendimiento (tiempo de build, tamaño de archivos)
- Configuraciones aplicadas
- Problemas encontrados y sus soluciones
- Lecciones aprendidas
- Recomendaciones para futuros despliegues

**Cuándo usar:** Como referencia para comparar despliegues futuros o para documentar el estado actual del despliegue.

### QUICK_START_DEPLOYMENT.md
**Propósito:** Guía rápida de inicio para realizar un despliegue básico.

**Contenido:**
- Pasos esenciales para desplegar
- Comandos básicos necesarios
- Verificaciones mínimas requeridas
- Enlaces a recursos adicionales

**Cuándo usar:** Para despliegues rápidos cuando ya tienes experiencia o necesitas un recordatorio de los pasos básicos.

## 🔧 Scripts de Bash

### deploy-to-pages.sh
**Propósito:** Script principal para desplegar la aplicación Flutter web en GitHub Pages.

**Funcionalidades:**
- Construcción optimizada de la aplicación Flutter para web
- Configuración de la base URL para GitHub Pages
- Manejo de recursos y assets
- Optimización de archivos HTML, CSS y JavaScript
- Push automático a la rama `gh-pages`

**Uso:**
```bash
./tools_deploy/deploy-to-pages.sh
```

**Requisitos:**
- Flutter SDK instalado
- Git configurado con permisos de push
- Rama `gh-pages` configurada

### initial-deploy.sh
**Propósito:** Script de configuración inicial para el primer despliegue.

**Funcionalidades:**
- Verificación de dependencias (Flutter, Git, etc.)
- Creación de la rama `gh-pages` si no existe
- Configuración inicial del repositorio
- Configuración de GitHub Pages en el repositorio
- Primer build y despliegue de prueba
- Validación de la configuración

**Uso:**
```bash
./tools_deploy/initial-deploy.sh
```

**Cuándo usar:** Solo la primera vez que configuras el despliegue o cuando necesitas resetear toda la configuración.

### monitor-deployment.sh
**Propósito:** Script de monitoreo y validación del despliegue.

**Funcionalidades:**
- Verificación del estado de GitHub Pages
- Comprobación de la disponibilidad del sitio
- Análisis de errores 404 y recursos faltantes
- Validación de certificados SSL
- Reporte de métricas de rendimiento
- Notificaciones de estado

**Uso:**
```bash
./tools_deploy/monitor-deployment.sh [URL_DEL_SITIO]
```

**Cuándo usar:** Después de cada despliegue para verificar que todo funciona correctamente.

### quick-deploy.sh
**Propósito:** Script simplificado para despliegues rápidos con configuración mínima.

**Funcionalidades:**
- Build rápido de Flutter web
- Push directo a `gh-pages`
- Verificación básica post-despliegue
- Logs simplificados

**Uso:**
```bash
./tools_deploy/quick-deploy.sh
```

**Cuándo usar:** Para actualizaciones menores o cuando necesitas desplegar rápidamente sin todas las validaciones.

## ⚙️ GitHub Actions Workflows

### deploy_web.yml
**Propósito:** Workflow básico de GitHub Actions para despliegue manual o programado.

**Características:**
- Trigger manual desde GitHub UI
- Configuración mínima de Flutter
- Build y despliegue básico
- Compatible con versiones antiguas de Flutter

**Activación:**
- Manual desde la pestaña Actions en GitHub
- Push a rama específica (configurable)

**Configuración requerida:**
```yaml
- Flutter version: 3.32.4
- Rama de despliegue: gh-pages
```

### flutter-web-deploy.yml
**Propósito:** Workflow completo y optimizado para CI/CD de Flutter web.

**Características:**
- Build optimizado con caché de dependencias
- Múltiples triggers (push, PR, manual)
- Validación de código antes del despliegue
- Tests automatizados
- Generación de artefactos
- Despliegue con verificación
- Notificaciones de estado
- Rollback automático en caso de fallo

**Activación:**
- Push a `main` o `develop`
- Pull Requests
- Trigger manual
- Programado (cron)

**Configuración avanzada:**
- Secretos de GitHub necesarios
- Variables de entorno
- Configuración de permisos
- Estrategias de caché

## 🔄 Flujo de Trabajo Recomendado

### Para el Primer Despliegue:
1. Ejecutar `initial-deploy.sh` para configurar todo
2. Revisar `AUTOMATED_DEPLOYMENT_TEMPLATE.md` para entender el proceso
3. Configurar el workflow `flutter-web-deploy.yml` en GitHub
4. Ejecutar `monitor-deployment.sh` para verificar

### Para Despliegues Regulares:
1. Hacer cambios en el código
2. Ejecutar `deploy-to-pages.sh` localmente o
3. Hacer push y dejar que GitHub Actions maneje el despliegue
4. Verificar con `monitor-deployment.sh`

### Para Despliegues Rápidos:
1. Usar `quick-deploy.sh` para cambios menores
2. Verificar el sitio manualmente

## 🛠️ Solución de Problemas Comunes

### Error: "gh-pages branch not found"
- Ejecutar `initial-deploy.sh` para crear la rama

### Error: "Flutter command not found"
- Verificar instalación de Flutter
- Agregar Flutter al PATH

### Error: "Permission denied"
- Dar permisos de ejecución: `chmod +x tools_deploy/*.sh`

### El sitio no se actualiza
- Verificar caché del navegador
- Esperar 5-10 minutos para propagación
- Revisar configuración en Settings > Pages

## 📋 Checklist Pre-Despliegue

- [ ] Flutter SDK actualizado
- [ ] Tests pasando localmente
- [ ] Build web funciona sin errores
- [ ] Assets y fuentes incluidos
- [ ] Configuración de base URL correcta
- [ ] Rama gh-pages existe y está configurada

## 🔗 Enlaces Útiles

- [Documentación de GitHub Pages](https://docs.github.com/pages)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [GitHub Actions para Flutter](https://github.com/marketplace/actions/flutter-action)

## 💡 Tips y Mejores Prácticas

1. **Siempre verificar localmente:** Ejecuta `flutter build web` antes de desplegar
2. **Usar caché:** Los workflows incluyen caché para acelerar builds
3. **Monitorear después de desplegar:** Usa `monitor-deployment.sh`
4. **Mantener documentación actualizada:** Actualiza los reportes después de cada despliegue importante
5. **Versionar los despliegues:** Usa tags de Git para marcar versiones desplegadas

## 📝 Notas Importantes

- Todos los scripts asumen que estás en la raíz del proyecto
- Los workflows requieren configuración de secretos en GitHub
- La rama `gh-pages` debe estar protegida en producción
- Siempre revisar los logs de GitHub Actions para debugging

---

**Última actualización:** Agosto 2025
**Mantenedor:** Equipo ALMA
**Versión de herramientas:** 1.0.0