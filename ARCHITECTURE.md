# Arquitectura de ALMA - Clean Architecture

## Visión General

ALMA sigue los principios de **Clean Architecture** para garantizar escalabilidad, testabilidad y mantenibilidad. La arquitectura está organizada en capas independientes con dependencias unidireccionales.

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  (UI Components, BLoCs/Cubits, Pages, Widgets)              │
└─────────────────────────────┬───────────────────────────────┘
                              │ depends on
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       Domain Layer                           │
│  (Entities, Use Cases, Repository Interfaces)                │
└─────────────────┬───────────────────────────────┬───────────┘
      depends on  │                               │ implements
                  ▼                               ▼
┌─────────────────────────────────────────────────────────────┐
│                        Data Layer                            │
│  (Repositories, Data Sources, Models, DTOs)                  │
└─────────────────────────────────────────────────────────────┘
```

## Estructura del Proyecto

```
lib/
├── config/                     # Configuración global
│   ├── routes/                # Navegación con go_router
│   └── theme/                 # Temas de la aplicación
│
├── core/                      # Elementos compartidos
│   ├── constants/            # Constantes globales
│   ├── error/                # Manejo de errores
│   ├── usecases/            # Casos de uso base
│   └── utils/               # Utilidades comunes
│
├── features/                  # Features modulares
│   └── color_game/           # Feature: Juego de colores
│       ├── domain/          # Lógica de negocio
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       ├── data/            # Implementación de datos
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       └── presentation/    # Capa de presentación
│           ├── bloc/
│           ├── pages/
│           └── widgets/
│
├── injection_container.dart   # Inyección de dependencias
└── main.dart                  # Punto de entrada

```

## Capas de la Arquitectura

### 1. Domain Layer (Capa de Dominio)
**Responsabilidad**: Contiene la lógica de negocio pura de la aplicación.

- **Entities**: Objetos de negocio fundamentales
- **Use Cases**: Operaciones de negocio específicas
- **Repository Interfaces**: Contratos para acceso a datos

**Reglas**:
- NO depende de ninguna otra capa
- NO contiene implementaciones técnicas
- Define interfaces, no implementaciones

### 2. Data Layer (Capa de Datos)
**Responsabilidad**: Implementa el acceso y persistencia de datos.

- **Models**: DTOs para serialización/deserialización
- **Data Sources**: Fuentes de datos (local/remoto)
- **Repository Implementations**: Implementaciones concretas

**Reglas**:
- Depende SOLO del Domain
- Maneja conversión entre Models y Entities
- Gestiona caché y sincronización

### 3. Presentation Layer (Capa de Presentación)
**Responsabilidad**: Maneja la interfaz de usuario y estado.

- **BLoCs/Cubits**: Gestión de estado con flutter_bloc
- **Pages**: Pantallas completas
- **Widgets**: Componentes reutilizables

**Reglas**:
- Depende SOLO del Domain
- NO conoce detalles de implementación de Data
- Maneja eventos de UI y actualiza la vista

## Flujo de Datos

### Ejemplo: Usuario selecciona un color

```
1. USER ACTION
   └─> ColorOptionButton.onPressed()
   
2. PRESENTATION
   └─> ColorGameBloc.add(AnswerSelectedEvent)
       └─> AnswerQuestion UseCase
   
3. DOMAIN
   └─> ColorGameRepository.updateSessionWithAnswer()
   
4. DATA
   └─> ColorGameRepositoryImpl
       └─> ColorGameLocalDataSource.saveSession()
   
5. RESPONSE FLOW (inverso)
   DATA -> DOMAIN -> PRESENTATION -> UI UPDATE
```

## Gestión de Estado

### BLoC Pattern
```dart
// Event
class AnswerSelectedEvent extends ColorGameEvent {
  final String selectedColor;
}

// State
class ColorGameReady extends ColorGameState {
  final GameSession session;
  final ColorQuestion currentQuestion;
}

// BLoC
class ColorGameBloc extends Bloc<ColorGameEvent, ColorGameState> {
  // Maneja eventos y emite nuevos estados
}
```

## Inyección de Dependencias

Utilizamos **get_it** para gestionar dependencias:

```dart
// Registro de dependencias
sl.registerFactory(() => ColorGameBloc(
  startGameSession: sl(),
  generateColorQuestion: sl(),
  answerQuestion: sl(),
));

// Uso
final bloc = sl<ColorGameBloc>();
```

## Testing Strategy

### 1. Unit Tests
- Domain: Use Cases, Entities
- Data: Repositories, Data Sources
- Presentation: BLoCs

### 2. Widget Tests
- Componentes individuales
- Interacciones de usuario

### 3. Integration Tests
- Flujos completos end-to-end
- Verificación de features

## Principios de Desarrollo

### SOLID Principles
- **S**ingle Responsibility
- **O**pen/Closed
- **L**iskov Substitution
- **I**nterface Segregation
- **D**ependency Inversion

### Clean Code
- Nombres descriptivos
- Funciones pequeñas y enfocadas
- Comentarios solo cuando añaden valor
- Tests como documentación

## Convenciones de Código

### Nomenclatura
- **Classes**: PascalCase (`ColorGameBloc`)
- **Files**: snake_case (`color_game_bloc.dart`)
- **Variables**: camelCase (`currentQuestion`)
- **Constants**: camelCase o SCREAMING_SNAKE_CASE

### Estructura de Features
Cada feature debe contener:
```
feature_name/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

## Decisiones Técnicas

### Estado: flutter_bloc
- Separación clara entre lógica y UI
- Testeable y predecible
- Soporte robusto de la comunidad

### Navegación: go_router
- Declarativa y type-safe
- Soporte para deep linking
- Compatible con web

### DI: get_it
- Simple y eficiente
- Sin generación de código requerida
- Lazy loading de dependencias

## Próximos Pasos

1. **Persistencia Local**: SharedPreferences para estadísticas
2. **Internacionalización**: Soporte multi-idioma
3. **Analytics**: Tracking de progreso
4. **Más Juegos**: Expandir features educativos
5. **Panel Parental**: Control y seguimiento