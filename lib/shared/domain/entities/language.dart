// Puedes poner esta clase en un archivo de modelos o al principio del archivo de la página de ajustes.
class LanguageOption {
  final String code; // ej: 'es', 'en'
  final String name; // ej: 'Español', 'English'
  final String flag; // ej: '🇪🇸', '🇬🇧' (emoji) o una ruta a un asset

  const LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
  });
}
