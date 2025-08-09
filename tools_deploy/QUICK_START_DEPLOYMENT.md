# QUICK START - Despliegue Flutter en GitHub Pages

## 🚀 Despliegue en 5 Minutos

### Opción A: Setup Completo Automatizado (Recomendado)
```bash
# Ejecutar setup completo
chmod +x scripts/setup-complete.sh
./scripts/setup-complete.sh

# Seguir instrucciones en pantalla para configurar GitHub Pages
# Hacer commit y push
git add .
git commit -m "Configure GitHub Pages deployment"
git push origin main
```

### Opción B: Deploy Manual Rápido
```bash
# Para deploy inmediato sin GitHub Actions
chmod +x scripts/quick-deploy.sh
./scripts/quick-deploy.sh
```

## 📋 Checklist Pre-Deploy

### Requisitos Mínimos
- [ ] Flutter 3.32.0+ instalado
- [ ] Repositorio Git con remote configurado
- [ ] Permisos de administrador en el repositorio

### Verificación Rápida
```bash
# Verificar versiones
flutter --version  # Debe ser 3.32.0+
git remote -v      # Debe mostrar origin

# Verificar proyecto
ls pubspec.yaml    # Debe existir
```

## 🔧 Configuración Manual GitHub Pages (Una vez)

1. Ir a: `https://github.com/[TU_USUARIO]/[TU_REPO]/settings/pages`
2. Source: **Deploy from a branch**
3. Branch: **gh-pages**
4. Folder: **/ (root)**
5. Click **Save**

## 📝 Archivos Clave Creados

| Archivo | Función |
|---------|---------|
| `.github/workflows/flutter-web-deploy.yml` | Pipeline CI/CD automatizado |
| `scripts/setup-complete.sh` | Setup inicial completo |
| `scripts/quick-deploy.sh` | Deploy manual rápido |
| `web/.nojekyll` | Evita procesamiento Jekyll |

## ⚡ Comandos Rápidos

```bash
# Setup inicial (una vez)
./scripts/setup-complete.sh

# Deploy manual rápido
./scripts/quick-deploy.sh

# Verificar estado
curl -I https://[usuario].github.io/[repo]/

# Ver logs de GitHub Actions
gh run list --workflow=flutter-web-deploy.yml
gh run view --log
```

## 🐛 Solución Rápida de Problemas

| Problema | Solución |
|----------|----------|
| Flutter version error | `flutter upgrade` a 3.32.0+ |
| flutter_lints error | Cambiar a v4 en pubspec.yaml |
| 404 en GitHub Pages | Configurar gh-pages en Settings |
| Build error 64 | NO usar --web-renderer |
| gh-pages no existe | El script la crea automáticamente |

## ✅ Versiones Probadas

- **Flutter**: 3.32.4
- **Dart**: 3.8.1+
- **flutter_lints**: 4.0.0
- **Ubuntu Runner**: ubuntu-latest

## 🎯 URLs Importantes

- **Tu sitio**: `https://[usuario].github.io/[repo]/`
- **Configuración**: `https://github.com/[usuario]/[repo]/settings/pages`
- **Actions**: `https://github.com/[usuario]/[repo]/actions`

## 📚 Documentación Completa

Para más detalles, consulta:
- `DEPLOYMENT_SUCCESS_REPORT.md` - Reporte completo del despliegue
- `AUTOMATED_DEPLOYMENT_TEMPLATE.md` - Guía detallada paso a paso
- `TROUBLESHOOTING_GUIDE.md` - Solución de problemas

---

**Última actualización**: 2025-08-09
**Probado con**: Proyecto ALMA