import 'package:flutter/material.dart';

/// Colores educativos para el juego de identificación
class GameColors {
  static const Map<String, Color> educationalColors = {
    'Rojo': Color(0xFFE53935),
    'Azul': Color(0xFF1E88E5),
    'Verde': Color(0xFF43A047),
    'Amarillo': Color(0xFFFDD835),
    'Naranja': Color(0xFFFB8C00),
    'Morado': Color(0xFF8E24AA),
    'Rosa': Color(0xFFD81B60),
    'Marrón': Color(0xFF6D4C41),
    'Negro': Color(0xFF212121),
    'Blanco': Color(0xFFF5F5F5),
  };

  static List<String> get colorNames => educationalColors.keys.toList();
  
  static Color getColor(String name) {
    return educationalColors[name] ?? Colors.grey;
  }
}

/// Colores del tema de la aplicación
class AppColors {
  static const Color primary = Color(0xFF6750A4);
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color secondary = Color(0xFF625B71);
  static const Color secondaryContainer = Color(0xFFE8DEF8);
  static const Color tertiary = Color(0xFF7D5260);
  static const Color tertiaryContainer = Color(0xFFFFD8E4);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color background = Color(0xFFFFFBFE);
  static const Color surface = Color(0xFFFFFBFE);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color outline = Color(0xFF79747E);
  static const Color shadow = Color(0xFF000000);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
}