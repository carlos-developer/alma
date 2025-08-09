# Estrategia de Versionado - Proyecto ALMA

## Sistema de Versionado Semántico Simplificado

Utilizamos versionado semántico (SemVer) adaptado para un desarrollador individual:

```
MAJOR.MINOR.PATCH
  1  .  0  .  0
```

### Definiciones

- **MAJOR** (1.x.x): Cambios grandes que modifican la experiencia del usuario
  - Nuevos juegos completos
  - Rediseño completo de la UI
  - Cambios que rompen compatibilidad

- **MINOR** (x.1.x): Nuevas características y mejoras
  - Nuevas funcionalidades en juegos existentes
  - Mejoras significativas de rendimiento
  - Nuevas pantallas o secciones

- **PATCH** (x.x.1): Correcciones y ajustes menores
  - Corrección de bugs
  - Ajustes de texto o colores
  - Optimizaciones menores

## Flujo de Trabajo Simple

### 1. Desarrollo Normal (branch: develop)
```bash
# Trabajar en develop
git checkout develop
# ... hacer cambios ...
git add .
git commit -m "feat: descripción del cambio"
```

### 2. Preparar Release (cuando hay suficientes cambios)
```bash
# En develop, actualizar versión en pubspec.yaml
# Cambiar version: "1.0.0+1" a "1.1.0+2" por ejemplo

# Commitear cambio de versión
git add pubspec.yaml
git commit -m "chore: bump version to 1.1.0"
```

### 3. Desplegar a Producción
```bash
# Cambiar a main
git checkout main
git merge develop

# Crear tag de versión
git tag -a v1.1.0 -m "Release v1.1.0: Descripción de cambios principales"

# Push con tags
git push origin main --tags
```

## Automatización con GitHub Actions

El workflow detecta automáticamente los tags y:
1. Crea un Release en GitHub
2. Despliega la versión etiquetada
3. Guarda información de la versión

## Convención de Commits

Usa prefijos para claridad:

- `feat:` Nueva característica
- `fix:` Corrección de bug
- `docs:` Cambios en documentación
- `style:` Cambios de formato/estilo
- `refactor:` Refactorización de código
- `test:` Añadir o modificar tests
- `chore:` Tareas de mantenimiento

### Ejemplos:
```bash
git commit -m "feat: agregar nuevo juego de formas geométricas"
git commit -m "fix: corregir error en puntuación del juego"
git commit -m "style: mejorar colores en modo oscuro"
git commit -m "chore: actualizar dependencias"
```

## Registro de Versiones

### Versiones Publicadas

| Versión | Fecha | Cambios Principales |
|---------|-------|-------------------|
| v1.0.0  | 2025-08-09 | Release inicial - Juego de identificación de colores |
| v1.1.0  | *Próxima* | *Planificado: Mejoras en feedback visual* |
| v1.2.0  | *Futura* | *Planificado: Segundo juego educativo* |

### Roadmap Simplificado

#### Fase 1: MVP (v1.0.x) ✅
- [x] Juego básico de colores
- [x] Despliegue en GitHub Pages
- [ ] Correcciones post-lanzamiento

#### Fase 2: Mejoras (v1.1.x)
- [ ] Sonidos y efectos
- [ ] Animaciones mejoradas
- [ ] Modo práctica sin puntuación

#### Fase 3: Expansión (v1.2.x)
- [ ] Juego de formas geométricas
- [ ] Sistema de niveles
- [ ] Guardado de progreso local

#### Fase 4: Polish (v1.3.x)
- [ ] Modo oscuro
- [ ] Múltiples idiomas
- [ ] Tutorial interactivo

## Scripts Útiles

### Ver versión actual
```bash
grep "version:" pubspec.yaml
```

### Ver último tag
```bash
git describe --tags --abbrev=0
```

### Ver historial de versiones
```bash
git tag -l "v*" --sort=-version:refname
```

### Crear release rápido (script)
```bash
#!/bin/bash
# save as: scripts/release.sh

VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Uso: ./scripts/release.sh 1.1.0"
  exit 1
fi

# Actualizar pubspec.yaml
sed -i "s/version: .*/version: $VERSION+$GITHUB_RUN_NUMBER/" pubspec.yaml

# Commit y tag
git add pubspec.yaml
git commit -m "chore: release v$VERSION"
git tag -a "v$VERSION" -m "Release v$VERSION"

echo "Release v$VERSION preparado. Ejecuta:"
echo "  git push origin main --tags"
```

## Notas Importantes

1. **No te compliques**: Como desarrollador individual, mantén el versionado simple
2. **Documenta cambios**: Usa mensajes de commit descriptivos
3. **Test antes de release**: Siempre prueba en local antes de crear un tag
4. **No elimines tags**: Si cometes un error, crea un nuevo patch

## Comandos Rápidos de Emergencia

```bash
# Revertir último release (antes de push)
git tag -d v1.1.0
git reset --hard HEAD~1

# Crear hotfix rápido
git checkout main
# ... fix bug ...
git add .
git commit -m "fix: critical bug in color detection"
git tag -a v1.0.1 -m "Hotfix: Color detection"
git push origin main --tags
```

---

**Recuerda**: La simplicidad es clave. No necesitas un proceso complejo para un proyecto personal o de aprendizaje.