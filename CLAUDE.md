# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ALMA (Aprendizaje y Lógica para Mentes Activas) is an educational Flutter application designed to nurture children's knowledge through interactive games and activities. The project supports Android, iOS, and Web platforms.

## Common Development Commands

### Running the Application

```bash
# Run on default device
flutter run

# Run on web browser
flutter run -d chrome

# Run on specific device (list devices first)
flutter devices
flutter run -d [device-id]
```

### Building the Application

```bash
# Build for Android
flutter build apk
flutter build appbundle

# Build for iOS (macOS only)
flutter build ios

# Build for Web
flutter build web
```

### Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run a specific test file
flutter test test/widget_test.dart
```

### Code Quality

```bash
# Analyze code for issues
flutter analyze

# Format code
dart format lib/

# Check formatting without changing files
dart format --set-exit-if-changed lib/
```

### Dependencies

```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Clean and get dependencies
flutter clean && flutter pub get
```

## Architecture

### Project Structure

```
alma/
├── lib/               # Main application code
│   └── main.dart     # Entry point
├── test/             # Unit and widget tests
├── assets/           # Images, fonts, and other resources (when added)
├── android/          # Android-specific configuration
├── ios/             # iOS-specific configuration
└── web/             # Web-specific configuration
```

### Key Technical Decisions

- **State Management**: TBD - Will be decided as the project grows
- **Navigation**: TBD - Will implement based on app complexity
- **UI Framework**: Material Design (Material 3)
- **Minimum SDK**: Flutter 3.8.1+

## Development Guidelines

### Code Quality Requirements

**IMPORTANTE**: Como subagente de desarrollo, SIEMPRE debes:

1. **Ejecutar `flutter analyze` después de CADA cambio de código**
2. **NO dejar errores, warnings o info issues en el código**  
3. **Corregir TODOS los problemas antes de marcar una tarea como completada**
4. **El código debe quedar completamente limpio y sin errores**

```bash
# OBLIGATORIO: Ejecutar después de cada modificación
flutter analyze

# El resultado esperado debe ser:
# "No issues found!"
```

Si `flutter analyze` muestra problemas:
- **Errors (rojo)**: Deben corregirse INMEDIATAMENTE
- **Warnings (amarillo)**: Deben corregirse antes de continuar
- **Info (azul)**: Deben corregirse para mantener calidad del código

### Code Organization

- Create feature-based folders in `lib/` as the project grows
- Separate business logic from UI components
- Use meaningful file and class names in Spanish or English consistently

### Testing Strategy

- Write widget tests for all UI components
- Test user interactions and state changes
- Maintain test coverage for critical features

### Collaboration Notes

- This is a collaborative project with 20+ developers
- `pubspec.lock` must be committed for dependency consistency
- Never commit sensitive data (API keys, credentials)
- All web assets (icons, manifest) are versioned

## Important Considerations

### Multi-platform Support

- Test features on all platforms (Android, iOS, Web)
- Consider platform-specific UI adjustments when needed
- Ensure responsive design for different screen sizes

### Educational Focus

- Features should be child-friendly and intuitive
- Prioritize educational value in all game mechanics
- Consider accessibility for children with different abilities

### Security

- Never hardcode API keys or sensitive data
- Use environment variables for configuration
- Follow the `.gitignore` rules strictly

## Specialized Agents for Development

The project leverages specialized AI agents for optimal task execution. These agents are invoked both manually and proactively.

### Available Agents

1. **flutter-test-engineer**: Automated test creation specialist
2. **flutter-ui-ux-engineer**: UI/UX design and implementation expert
3. **cloud-devops-flutter-architect**: CI/CD and deployment specialist
4. **flutter-architect-alma**: Clean Architecture specialist for ALMA

### Proactive Agent Activation

Agents are automatically invoked when specific patterns are detected:

- **Testing Agent**: Activated after implementing new features, creating BLoCs/Cubits, or modifying critical business logic
- **UI/UX Agent**: Triggered when creating screens, improving user experience, or implementing responsive designs
- **DevOps Agent**: Engaged for deployment tasks, CI/CD configuration, or release planning
- **Architecture Agent**: Invoked when adding complex features, restructuring modules, or reviewing architectural compliance

### Manual Activation Keywords

Start your message with these keywords to manually invoke agents:

- **Testing**: `test`, `testing`, `pruebas`
- **UI/UX**: `diseñador`, `ui`, `ux`, `interfaz`
- **DevOps**: `devops`, `deploy`, `ci/cd`, `pipeline`
- **Architecture**: `arquitectura`, `arquitecto`, `estructura`

For detailed agent documentation, see `.claude/README.md`

## MCP (Model Context Protocol) Integration

### GitHub Integration via MCP

The project is configured to use MCP for GitHub integration, enabling direct interaction with repositories, issues, and pull requests.

#### Setup Instructions

1. **Run the setup script:**
   ```bash
   ./setup-mcp-github.sh
   ```

2. **Configure your GitHub token in `.env.mcp`:**
   ```bash
   GITHUB_TOKEN=your_personal_access_token_here
   ```

3. **Get your token from:** https://github.com/settings/tokens
   Required permissions:
   - `repo` (full repository access)
   - `workflow` (GitHub Actions)
   - `read:org` (organization repositories)

#### Available MCP GitHub Commands

Use these commands with Claude Code after MCP is configured:

```bash
# Repository Management
"lista mis repositorios de GitHub"
"muestra información del repositorio alma"
"crea un nuevo repositorio llamado [nombre]"

# Issues & PRs
"lista los issues abiertos"
"crea un issue para [descripción]"
"muestra los pull requests pendientes"
"crea un PR para el feature actual"

# GitHub Actions
"muestra el estado del último workflow"
"ejecuta el workflow de deploy"

# Collaboration
"lista los colaboradores del proyecto"
"muestra la actividad reciente del repositorio"
```

#### MCP Configuration Files

- `.claude/mcp_config.json` - MCP server configuration
- `.env.mcp` - Environment variables (gitignored)
- `setup-mcp-github.sh` - Automated setup script

## Future Implementations

As the project evolves, this document will be updated with:
- Chosen state management solution
- API integration patterns
- Database schema and models
- Routing and navigation structure
- Internationalization approach
- Additional MCP integrations (Jira, Figma, FlutterFlow)