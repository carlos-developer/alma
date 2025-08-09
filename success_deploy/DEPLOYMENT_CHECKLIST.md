# ALMA - Checklist de Despliegue a GitHub Pages

## Pre-Despliegue

### Verificación del Código
- [ ] Todos los tests pasan (`flutter test`)
- [ ] El análisis de código está limpio (`flutter analyze`)
- [ ] El build local funciona (`flutter build web --release --base-href /alma/`)
- [ ] La aplicación funciona correctamente en local
- [ ] No hay información sensible en el código

### Verificación de Git
- [ ] Estás en la rama correcta (`develop` para desarrollo, `main` para producción)
- [ ] No hay cambios sin commitear (`git status`)
- [ ] El código está sincronizado con el remoto (`git pull`)
- [ ] Los cambios están probados y revisados

### Verificación de Archivos
- [ ] `.github/workflows/flutter-web-deploy.yml` existe
- [ ] `web/.nojekyll` existe
- [ ] `pubspec.yaml` tiene la versión correcta
- [ ] No hay archivos temporales o de build commiteados

## Durante el Despliegue

### Si estás en `develop`:
1. [ ] Cambiar a main: `git checkout main`
2. [ ] Actualizar main: `git pull origin main`
3. [ ] Mergear develop: `git merge develop`
4. [ ] Resolver conflictos si los hay
5. [ ] Hacer push: `git push origin main`

### Si estás en `main`:
1. [ ] Hacer push directamente: `git push origin main`

### Monitoreo del Despliegue
- [ ] Ir a la pestaña Actions: https://github.com/[usuario]/alma/actions
- [ ] Verificar que el workflow "Deploy ALMA to GitHub Pages" se está ejecutando
- [ ] Esperar a que termine (3-5 minutos aproximadamente)
- [ ] Verificar que no hay errores en el log

## Post-Despliegue

### Verificación Inmediata (Primeros 5 minutos)
- [ ] El workflow terminó exitosamente (check verde)
- [ ] La rama `gh-pages` fue creada/actualizada
- [ ] No hay errores en el log del workflow

### Verificación del Sitio (5-10 minutos después)
- [ ] Acceder a https://[usuario].github.io/alma/
- [ ] La página carga correctamente
- [ ] Los estilos se ven bien
- [ ] El juego de colores funciona
- [ ] La navegación funciona correctamente
- [ ] No hay errores en la consola del navegador (F12)

### Verificación de Rendimiento
- [ ] El tiempo de carga inicial es aceptable (< 3 segundos)
- [ ] Las interacciones son fluidas
- [ ] Los recursos se cargan correctamente (imágenes, fuentes)
- [ ] El sitio es responsive (prueba en móvil)

## Configuración de GitHub Pages (Solo Primera Vez)

1. [ ] Ir a Settings → Pages
2. [ ] En Source, seleccionar "Deploy from a branch"
3. [ ] En Branch, seleccionar "gh-pages" y "/ (root)"
4. [ ] Hacer clic en Save
5. [ ] Esperar 5-10 minutos para la primera activación
6. [ ] Verificar que aparece la URL del sitio

## Troubleshooting Rápido

### El workflow falla
- Revisar el log del workflow en Actions
- Verificar la versión de Flutter en el workflow
- Comprobar que flutter_lints no sea v5 en pubspec.yaml
- Revisar si hay errores de sintaxis en el código

### El sitio no carga (404)
- Verificar que GitHub Pages está habilitado
- Confirmar que la rama gh-pages existe
- Esperar 10 minutos (primera vez puede tardar más)
- Verificar el base-href en el workflow (/alma/)

### Los estilos no cargan
- Verificar que .nojekyll existe en gh-pages
- Comprobar el base-href en index.html
- Limpiar caché del navegador (Ctrl+F5)

### El juego no funciona
- Abrir consola del navegador (F12)
- Buscar errores de JavaScript
- Verificar que el web renderer es correcto (canvaskit)
- Probar en otro navegador

## Rollback de Emergencia

Si algo sale mal y necesitas revertir:

```bash
# Opción 1: Revertir el último commit
git revert HEAD
git push origin main

# Opción 2: Volver a un commit anterior conocido
git reset --hard [commit-hash]
git push origin main --force

# Opción 3: Desplegar manualmente una versión anterior
# Ve a Actions → Selecciona un workflow exitoso anterior → Re-run jobs
```

## Comandos Útiles

```bash
# Ver estado del despliegue
gh run list --workflow=flutter-web-deploy.yml

# Ver logs del último despliegue
gh run view --log

# Forzar un nuevo despliegue
git commit --allow-empty -m "trigger: force deployment"
git push origin main

# Verificar la rama gh-pages
git fetch origin gh-pages
git log origin/gh-pages --oneline -5
```

## Métricas de Éxito

- ✅ Build time < 5 minutos
- ✅ Tamaño del bundle < 10MB
- ✅ Time to Interactive < 3 segundos
- ✅ Sin errores en consola
- ✅ 100% de funcionalidades operativas

## Contacto y Soporte

Para un desarrollador individual, ten estos recursos a mano:

- Documentación Flutter Web: https://flutter.dev/web
- GitHub Pages docs: https://docs.github.com/pages
- Flutter Discord: https://discord.gg/flutter
- Stack Overflow: Tag [flutter-web]

---

**Última actualización**: 2025-08-09
**Versión**: 1.0.0
**Proyecto**: ALMA - MVP de identificación de colores