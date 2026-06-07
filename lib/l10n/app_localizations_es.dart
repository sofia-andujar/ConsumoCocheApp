// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Consumo Mazda 2 Sofía';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get averageConsumption => 'Consumo medio';

  @override
  String get addAtLeastOneRefuel => 'Añade al menos 1 repostaje';

  @override
  String get addRefuel => 'Añadir repostaje';

  @override
  String get refuelAddedSuccessfully => 'Repostaje añadido correctamente';

  @override
  String get reset => 'Restablecer';

  @override
  String get resetZoom => 'Restablecer zoom';

  @override
  String get history => 'Historial';

  @override
  String get sort => 'Ordenar';

  @override
  String get sortDate => 'Fecha';

  @override
  String get sortConsumption => 'Consumo';

  @override
  String get sortDistance => 'Distancia';

  @override
  String get sortLiters => 'Litros';

  @override
  String get filterByDate => 'Filtrar por fecha';

  @override
  String get dateFrom => 'Desde';

  @override
  String get dateTo => 'Hasta';

  @override
  String get selectDate => 'Seleccionar';

  @override
  String get clear => 'Limpiar';

  @override
  String get apply => 'Aplicar';

  @override
  String get noRefuelsRegistered => 'No hay repostajes registrados.';

  @override
  String get noRefuelsInRange => 'No hay repostajes en ese rango de fechas.';

  @override
  String get deleteAll => 'Eliminar todos';

  @override
  String get confirmDeleteAll =>
      '¿Estás seguro de que deseas eliminar todos los registros? Esta acción no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String deletedRecords(int count) {
    return 'Eliminados $count registros';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String get deleteRefuel => 'Eliminar repostaje';

  @override
  String confirmDeleteRefuel(String date, String consumption) {
    return '¿Eliminar el repostaje del $date ($consumption L/100km)?';
  }

  @override
  String get refuelDeleted => 'Repostaje eliminado';

  @override
  String get deleteAllRecords => 'Eliminar todos los registros';

  @override
  String get editRefuel => 'Editar repostaje';

  @override
  String get date => 'Fecha';

  @override
  String get distanceKm => 'Distancia (km)';

  @override
  String get required => 'Requerido';

  @override
  String get invalid => 'Inválido';

  @override
  String get mustBeGreaterThanZero => 'Debe ser > 0';

  @override
  String get liters => 'Litros';

  @override
  String get commentOptional => 'Comentario (opcional)';

  @override
  String get addNote => 'Añade una nota';

  @override
  String get update => 'Actualizar';

  @override
  String get save => 'Guardar';

  @override
  String get enterDistance => 'Introduce la distancia del trayecto';

  @override
  String get invalidNumericValue => 'Valor numérico inválido';

  @override
  String get mustBeGreaterThanZeroFull => 'Debe ser mayor que 0';

  @override
  String get litersRefueled => 'Litros repostados';

  @override
  String get enterLiters => 'Introduce los litros';

  @override
  String get addNoteFull => 'Añade una nota sobre este repostaje';

  @override
  String get saveRefuel => 'Guardar repostaje';

  @override
  String get deleteRefuelTooltip => 'Eliminar repostaje';

  @override
  String get editRefuelTooltip => 'Editar repostaje';

  @override
  String get addRefuelsToSeeChart =>
      'Añade repostajes para ver la evolución del consumo.';

  @override
  String get consumptionEvolution => 'Evolución consumo';

  @override
  String get legendConsumption => 'Consumo';

  @override
  String get legendMean => 'Media';

  @override
  String get legendAo5 => 'Ao5';

  @override
  String get noVisibleLines =>
      'No hay líneas visibles. Toca una leyenda para mostrarla.';

  @override
  String get customizeTheme => 'Personalizar tema';

  @override
  String get accentColor => 'Color de acento';

  @override
  String get visualMode => 'Modo visual';

  @override
  String get lightMode => 'Claro';

  @override
  String get darkMode => 'Oscuro';

  @override
  String get systemMode => 'Sistema';

  @override
  String get settingsPersist =>
      'Los cambios se guardan y persisten entre sesiones.';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get catalan => 'Català';
}
