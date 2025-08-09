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

## Future Implementations

As the project evolves, this document will be updated with:
- Chosen state management solution
- API integration patterns
- Database schema and models
- Routing and navigation structure
- Internationalization approach