// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'Consum Mazda 2 Sofia';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get averageConsumption => 'Consum mitjà';

  @override
  String get addAtLeastOneRefuel => 'Afegeix almenys 1 repostatge';

  @override
  String get addRefuel => 'Afegir repostatge';

  @override
  String get refuelAddedSuccessfully => 'Repostatge afegit correctament';

  @override
  String get reset => 'Restablir';

  @override
  String get resetZoom => 'Restablir zoom';

  @override
  String get history => 'Historial';

  @override
  String get sort => 'Ordenar';

  @override
  String get sortDate => 'Data';

  @override
  String get sortConsumption => 'Consum';

  @override
  String get sortDistance => 'Distància';

  @override
  String get sortLiters => 'Litres';

  @override
  String get filterByDate => 'Filtrar per data';

  @override
  String get dateFrom => 'Des de';

  @override
  String get dateTo => 'Fins a';

  @override
  String get selectDate => 'Seleccionar';

  @override
  String get clear => 'Netejar';

  @override
  String get apply => 'Aplicar';

  @override
  String get noRefuelsRegistered => 'No hi ha repostatges registrats.';

  @override
  String get noRefuelsInRange =>
      'No hi ha repostatges en aquest rang de dates.';

  @override
  String get deleteAll => 'Eliminar tots';

  @override
  String get confirmDeleteAll =>
      'Estàs segur que vols eliminar tots els registres? Aquesta acció no es pot desfer.';

  @override
  String get cancel => 'Cancel·lar';

  @override
  String get delete => 'Eliminar';

  @override
  String deletedRecords(int count) {
    return 'Eliminats $count registres';
  }

  @override
  String get undo => 'Desfer';

  @override
  String get deleteRefuel => 'Eliminar repostatge';

  @override
  String confirmDeleteRefuel(String date, String consumption) {
    return 'Eliminar el repostatge del $date ($consumption L/100km)?';
  }

  @override
  String get refuelDeleted => 'Repostatge eliminat';

  @override
  String get deleteAllRecords => 'Eliminar tots els registres';

  @override
  String get editRefuel => 'Editar repostatge';

  @override
  String get date => 'Data';

  @override
  String get distanceKm => 'Distància (km)';

  @override
  String get required => 'Requerit';

  @override
  String get invalid => 'Invàlid';

  @override
  String get mustBeGreaterThanZero => 'Ha de ser > 0';

  @override
  String get liters => 'Litres';

  @override
  String get commentOptional => 'Comentari (opcional)';

  @override
  String get addNote => 'Afegeix una nota';

  @override
  String get update => 'Actualitzar';

  @override
  String get save => 'Desar';

  @override
  String get enterDistance => 'Introdueix la distància del trajecte';

  @override
  String get invalidNumericValue => 'Valor numèric invàlid';

  @override
  String get mustBeGreaterThanZeroFull => 'Ha de ser major que 0';

  @override
  String get litersRefueled => 'Litres repostats';

  @override
  String get enterLiters => 'Introdueix els litres';

  @override
  String get addNoteFull => 'Afegeix una nota sobre aquest repostatge';

  @override
  String get saveRefuel => 'Desar repostatge';

  @override
  String get deleteRefuelTooltip => 'Eliminar repostatge';

  @override
  String get editRefuelTooltip => 'Editar repostatge';

  @override
  String get addRefuelsToSeeChart =>
      'Afegeix repostatges per veure l\'evolució del consum.';

  @override
  String get consumptionEvolution => 'Evolució consum';

  @override
  String get legendConsumption => 'Consum';

  @override
  String get legendMean => 'Mitjana';

  @override
  String get legendAo5 => 'Mitj5';

  @override
  String get noVisibleLines =>
      'No hi ha línies visibles. Toca una llegenda per mostrar-la.';

  @override
  String get customizeTheme => 'Personalitzar tema';

  @override
  String get accentColor => 'Color d\'accent';

  @override
  String get visualMode => 'Mode visual';

  @override
  String get lightMode => 'Clar';

  @override
  String get darkMode => 'Fosc';

  @override
  String get systemMode => 'Sistema';

  @override
  String get settingsPersist =>
      'Els canvis es desen i persisteixen entre sessions.';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get catalan => 'Català';
}
