import 'package:bcv_tracker_app/shared/domain/entities/currency.dart'; // Importa tu clase base
import 'package:equatable/equatable.dart';

/// Representa una moneda que puede ser usada en un cálculo de conversión.
///
/// Contiene el valor original [originalValue] de la moneda base (ej. USD)
/// y un valor calculado [convertedValue] que representa la cantidad
/// en la moneda de destino (ej. VES).
class ConvertibleCurrency extends Equatable {
  final Currency currency; // 1. Objeto base inmutable
  final double convertedValue; // 2. El valor que será alterado/calculado

  const ConvertibleCurrency({
    required this.currency,
    required this.convertedValue,
  });

  /// Propiedad de conveniencia para acceder al valor original inmutable.
  double get originalValue => currency.value;

  /// Propiedad de conveniencia para acceder al nombre de la moneda.
  String get name => currency.name;

  /// Propiedad de conveniencia para acceder a la clave de la moneda.
  String get keyName => currency.keyName;

  /// Crea una copia de la instancia actual con valores modificados.
  /// Esto es útil para actualizar el estado de forma inmutable.
  ConvertibleCurrency copyWith({Currency? currency, double? convertedValue}) {
    return ConvertibleCurrency(
      currency: currency ?? this.currency,
      convertedValue: convertedValue ?? this.convertedValue,
    );
  }

  // 3. Sobrescribimos `props` de Equatable para una comparación correcta.
  // Dos `ConvertibleCurrency` son iguales si su moneda base es la misma.
  @override
  List<Object?> get props => [currency, convertedValue];
}
