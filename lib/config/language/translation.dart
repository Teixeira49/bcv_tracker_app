// lib/app/config/localization/app_translations.dart

import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    // --- Inglés (US) ---
    'en_US': {
      'app_title': 'My Awesome App',
      'hello': 'Hello',
      'welcome_message': 'Welcome to our application!',
      'greeting': 'Hello @name, how are you?',
      'items_available': 'There is @count item available. | There are @count items available.',
      'change_language': 'Change Language',
      'spanish': 'Spanish',
      'english': 'English',
      'french': 'French',
    },
    // --- Español (ES) ---
    'es_ES': {
      'app_title': 'Mi Aplicación Increíble',
      'hello': 'Hola',
      'welcome_message': '¡Bienvenido a nuestra aplicación!',
      'greeting': 'Hola @name, ¿cómo estás?',
      'items_available': 'Hay @count artículo disponible. | Hay @count artículos disponibles.',
      'change_language': 'Cambiar Idioma',
      'spanish': 'Español',
      'english': 'Inglés',
      'french': 'Francés',
    },
    // --- Francés (FR) ---
    'fr_FR': {
      'app_title': 'Mon Application Impressionnante',
      'hello': 'Bonjour',
      'welcome_message': 'Bienvenue sur notre application !',
      'greeting': 'Bonjour @name, comment vas-tu ?',
      'items_available': 'Il y a @count article disponible. | Il y a @count articles disponibles.',
      'change_language': 'Changer de Langue',
      'spanish': 'Espagnol',
      'english': 'Anglais',
      'french': 'Français',
    }
    // ... puedes añadir más idiomas aquí
  };
}
