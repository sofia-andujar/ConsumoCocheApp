// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'Tank Up';

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
  String get zoomOut => 'Allunyar';

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

  @override
  String get unrealisticDistance => 'Distància no realista (max 5000 km)';

  @override
  String get unrealisticLiters => 'Litres no realistes (max 200 L)';

  @override
  String get retry => 'Reintentar';

  @override
  String get exportData => 'Exportar dades';

  @override
  String get exportDataDescription =>
      'Exporta l\'historial de repostatges com a fitxer CSV.';

  @override
  String get exportDataCsv => 'Exportar CSV';

  @override
  String get exportDataSuccess => 'Fitxer exportat';

  @override
  String get exportDataError => 'Error en l\'exportació';

  @override
  String get googleAccount => 'Compte de Google';

  @override
  String get signInWithGoogle => 'Iniciar sessió amb Google';

  @override
  String signedInAs(String email) {
    return 'Sessió: $email';
  }

  @override
  String get signOut => 'Tancar sessió';

  @override
  String get backupData => 'Fer còpia de seguretat';

  @override
  String get backupDataDescription =>
      'Desa una còpia de l\'historial a Google Drive.';

  @override
  String get backupButton => 'Fer còpia';

  @override
  String get backupSuccess => 'Dades desades correctament';

  @override
  String backupError(String error) {
    return 'Error en la còpia: $error';
  }

  @override
  String get restoreData => 'Restaurar dades';

  @override
  String get restoreDataDescription =>
      'Restaura l\'historial des de Google Drive.';

  @override
  String get restoreButton => 'Restaurar';

  @override
  String get restoreConfirm =>
      'Restaurar dades? Les dades actuals seran reemplaçades.';

  @override
  String get restoreSuccess => 'Dades restaurades correctament';

  @override
  String restoreError(String error) {
    return 'Error en restaurar: $error';
  }

  @override
  String get noBackupFound =>
      'No s\'ha trobat cap còpia. Fes una còpia primer.';

  @override
  String get signInRequired =>
      'Inicia sessió amb Google per fer còpia de seguretat.';

  @override
  String get driveScopeRequired =>
      'Concedeix permís a Google Drive per fer còpia de seguretat.';

  @override
  String get confirmReplaceData =>
      'Les dades actuals seran reemplaçades per la còpia.';

  @override
  String lastBackup(String date) {
    return 'Última còpia: $date';
  }

  @override
  String get importData => 'Importar dades';

  @override
  String get importDataDescription =>
      'Importa l\'historial de repostatges des d\'un fitxer CSV.';

  @override
  String get importDataCsv => 'Importar CSV';

  @override
  String importDataSuccess(int count) {
    return 'Importats $count repostatges';
  }

  @override
  String get importDataError => 'Error en la importació';
}
