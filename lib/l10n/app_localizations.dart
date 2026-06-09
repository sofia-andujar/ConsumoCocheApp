import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es')
  ];

  /// App title shown in the home screen AppBar
  ///
  /// In es, this message translates to:
  /// **'Consumo Mazda 2 Sofía'**
  String get appTitle;

  /// Generic error message
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(String error);

  /// Label for average consumption card
  ///
  /// In es, this message translates to:
  /// **'Consumo medio'**
  String get averageConsumption;

  /// Shown when there are no refuels
  ///
  /// In es, this message translates to:
  /// **'Añade al menos 1 repostaje'**
  String get addAtLeastOneRefuel;

  /// Title for add refuel form/screen
  ///
  /// In es, this message translates to:
  /// **'Añadir repostaje'**
  String get addRefuel;

  /// Snackbar after adding a refuel
  ///
  /// In es, this message translates to:
  /// **'Repostaje añadido correctamente'**
  String get refuelAddedSuccessfully;

  /// Reset zoom button label
  ///
  /// In es, this message translates to:
  /// **'Restablecer'**
  String get reset;

  /// Reset zoom button in fullscreen chart
  ///
  /// In es, this message translates to:
  /// **'Restablecer zoom'**
  String get resetZoom;

  /// History screen title
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get history;

  /// Sort button tooltip
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get sort;

  /// Sort by date
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get sortDate;

  /// Sort by consumption
  ///
  /// In es, this message translates to:
  /// **'Consumo'**
  String get sortConsumption;

  /// Sort by distance
  ///
  /// In es, this message translates to:
  /// **'Distancia'**
  String get sortDistance;

  /// Sort by liters
  ///
  /// In es, this message translates to:
  /// **'Litros'**
  String get sortLiters;

  /// Filter section title
  ///
  /// In es, this message translates to:
  /// **'Filtrar por fecha'**
  String get filterByDate;

  /// Start date label
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get dateFrom;

  /// End date label
  ///
  /// In es, this message translates to:
  /// **'Hasta'**
  String get dateTo;

  /// Date placeholder
  ///
  /// In es, this message translates to:
  /// **'Seleccionar'**
  String get selectDate;

  /// Clear filters button
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get clear;

  /// Apply filters button
  ///
  /// In es, this message translates to:
  /// **'Aplicar'**
  String get apply;

  /// Empty state message
  ///
  /// In es, this message translates to:
  /// **'No hay repostajes registrados.'**
  String get noRefuelsRegistered;

  /// No refuels in selected date range
  ///
  /// In es, this message translates to:
  /// **'No hay repostajes en ese rango de fechas.'**
  String get noRefuelsInRange;

  /// Delete all dialog title
  ///
  /// In es, this message translates to:
  /// **'Eliminar todos'**
  String get deleteAll;

  /// Confirm delete all dialog content
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar todos los registros? Esta acción no se puede deshacer.'**
  String get confirmDeleteAll;

  /// Cancel button
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Delete button
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// Snackbar after bulk delete
  ///
  /// In es, this message translates to:
  /// **'Eliminados {count} registros'**
  String deletedRecords(int count);

  /// Undo snackbar action
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get undo;

  /// Delete single refuel dialog title
  ///
  /// In es, this message translates to:
  /// **'Eliminar repostaje'**
  String get deleteRefuel;

  /// Confirm delete single refuel
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar el repostaje del {date} ({consumption} L/100km)?'**
  String confirmDeleteRefuel(String date, String consumption);

  /// Snackbar after deleting a refuel
  ///
  /// In es, this message translates to:
  /// **'Repostaje eliminado'**
  String get refuelDeleted;

  /// Delete all records bottom button
  ///
  /// In es, this message translates to:
  /// **'Eliminar todos los registros'**
  String get deleteAllRecords;

  /// Title when editing a refuel
  ///
  /// In es, this message translates to:
  /// **'Editar repostaje'**
  String get editRefuel;

  /// Date field label
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get date;

  /// Distance field label
  ///
  /// In es, this message translates to:
  /// **'Distancia (km)'**
  String get distanceKm;

  /// Required field validation
  ///
  /// In es, this message translates to:
  /// **'Requerido'**
  String get required;

  /// Invalid value validation (short)
  ///
  /// In es, this message translates to:
  /// **'Inválido'**
  String get invalid;

  /// Must be > 0 validation (short)
  ///
  /// In es, this message translates to:
  /// **'Debe ser > 0'**
  String get mustBeGreaterThanZero;

  /// Liters field label (compact)
  ///
  /// In es, this message translates to:
  /// **'Litros'**
  String get liters;

  /// Comment field label
  ///
  /// In es, this message translates to:
  /// **'Comentario (opcional)'**
  String get commentOptional;

  /// Comment hint (compact)
  ///
  /// In es, this message translates to:
  /// **'Añade una nota'**
  String get addNote;

  /// Update button
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get update;

  /// Save button (compact)
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// Distance validation (full form)
  ///
  /// In es, this message translates to:
  /// **'Introduce la distancia del trayecto'**
  String get enterDistance;

  /// Invalid numeric value validation
  ///
  /// In es, this message translates to:
  /// **'Valor numérico inválido'**
  String get invalidNumericValue;

  /// Must be > 0 validation (full form)
  ///
  /// In es, this message translates to:
  /// **'Debe ser mayor que 0'**
  String get mustBeGreaterThanZeroFull;

  /// Liters field label (full form)
  ///
  /// In es, this message translates to:
  /// **'Litros repostados'**
  String get litersRefueled;

  /// Liters validation (full form)
  ///
  /// In es, this message translates to:
  /// **'Introduce los litros'**
  String get enterLiters;

  /// Comment hint (full form)
  ///
  /// In es, this message translates to:
  /// **'Añade una nota sobre este repostaje'**
  String get addNoteFull;

  /// Save button (full form)
  ///
  /// In es, this message translates to:
  /// **'Guardar repostaje'**
  String get saveRefuel;

  /// Delete refuel icon tooltip
  ///
  /// In es, this message translates to:
  /// **'Eliminar repostaje'**
  String get deleteRefuelTooltip;

  /// Edit refuel icon tooltip
  ///
  /// In es, this message translates to:
  /// **'Editar repostaje'**
  String get editRefuelTooltip;

  /// Empty chart message
  ///
  /// In es, this message translates to:
  /// **'Añade repostajes para ver la evolución del consumo.'**
  String get addRefuelsToSeeChart;

  /// Chart title
  ///
  /// In es, this message translates to:
  /// **'Evolución consumo'**
  String get consumptionEvolution;

  /// Chart legend: consumption line
  ///
  /// In es, this message translates to:
  /// **'Consumo'**
  String get legendConsumption;

  /// Chart legend: mean line
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get legendMean;

  /// Chart legend: average of 5 line
  ///
  /// In es, this message translates to:
  /// **'Ao5'**
  String get legendAo5;

  /// No visible chart lines message
  ///
  /// In es, this message translates to:
  /// **'No hay líneas visibles. Toca una leyenda para mostrarla.'**
  String get noVisibleLines;

  /// Settings screen title
  ///
  /// In es, this message translates to:
  /// **'Personalizar tema'**
  String get customizeTheme;

  /// Accent color setting label
  ///
  /// In es, this message translates to:
  /// **'Color de acento'**
  String get accentColor;

  /// Visual/brightness mode setting label
  ///
  /// In es, this message translates to:
  /// **'Modo visual'**
  String get visualMode;

  /// Light theme mode
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get lightMode;

  /// Dark theme mode
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get darkMode;

  /// System theme mode
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get systemMode;

  /// Settings footer text
  ///
  /// In es, this message translates to:
  /// **'Los cambios se guardan y persisten entre sesiones.'**
  String get settingsPersist;

  /// Language setting label
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// Spanish language option
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// English language option
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// Catalan language option
  ///
  /// In es, this message translates to:
  /// **'Català'**
  String get catalan;

  /// Validation for unrealistic distance
  ///
  /// In es, this message translates to:
  /// **'Distancia no realista (max 5000 km)'**
  String get unrealisticDistance;

  /// Validation for unrealistic liters
  ///
  /// In es, this message translates to:
  /// **'Litros no realistas (max 200 L)'**
  String get unrealisticLiters;

  /// Retry button label
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// Export data card title
  ///
  /// In es, this message translates to:
  /// **'Exportar datos'**
  String get exportData;

  /// Export data card description
  ///
  /// In es, this message translates to:
  /// **'Exporta el historial de repostajes como archivo CSV.'**
  String get exportDataDescription;

  /// Export CSV button label
  ///
  /// In es, this message translates to:
  /// **'Exportar CSV'**
  String get exportDataCsv;

  /// Export data success message
  ///
  /// In es, this message translates to:
  /// **'Archivo exportado'**
  String get exportDataSuccess;

  /// Export data error message
  ///
  /// In es, this message translates to:
  /// **'Error al exportar'**
  String get exportDataError;

  /// Google account section title
  ///
  /// In es, this message translates to:
  /// **'Cuenta de Google'**
  String get googleAccount;

  /// Sign in with Google button
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión con Google'**
  String get signInWithGoogle;

  /// Shows signed in email
  ///
  /// In es, this message translates to:
  /// **'Sesión: {email}'**
  String signedInAs(String email);

  /// Sign out button
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get signOut;

  /// Backup data card title
  ///
  /// In es, this message translates to:
  /// **'Respaldar datos'**
  String get backupData;

  /// Backup data card description
  ///
  /// In es, this message translates to:
  /// **'Guarda una copia del historial en Google Drive.'**
  String get backupDataDescription;

  /// Backup button label
  ///
  /// In es, this message translates to:
  /// **'Respaldar'**
  String get backupButton;

  /// Backup success message
  ///
  /// In es, this message translates to:
  /// **'Datos respaldados correctamente'**
  String get backupSuccess;

  /// Backup error message
  ///
  /// In es, this message translates to:
  /// **'Error al respaldar: {error}'**
  String backupError(String error);

  /// Restore data card title
  ///
  /// In es, this message translates to:
  /// **'Restaurar datos'**
  String get restoreData;

  /// Restore data card description
  ///
  /// In es, this message translates to:
  /// **'Restaura el historial desde Google Drive.'**
  String get restoreDataDescription;

  /// Restore button label
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get restoreButton;

  /// Restore confirmation dialog message
  ///
  /// In es, this message translates to:
  /// **'¿Restaurar datos? Los datos actuales serán reemplazados.'**
  String get restoreConfirm;

  /// Restore success message
  ///
  /// In es, this message translates to:
  /// **'Datos restaurados correctamente'**
  String get restoreSuccess;

  /// Restore error message
  ///
  /// In es, this message translates to:
  /// **'Error al restaurar: {error}'**
  String restoreError(String error);

  /// No backup found message
  ///
  /// In es, this message translates to:
  /// **'No se encontró ningún respaldo. Haz un respaldo primero.'**
  String get noBackupFound;

  /// Sign in required message
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión con Google para respaldar tus datos.'**
  String get signInRequired;

  /// Google Drive permission required message
  ///
  /// In es, this message translates to:
  /// **'Concede permiso a Google Drive para respaldar tus datos.'**
  String get driveScopeRequired;

  /// Confirm replace data dialog body
  ///
  /// In es, this message translates to:
  /// **'Los datos actuales serán reemplazados por los del respaldo.'**
  String get confirmReplaceData;

  /// Last backup date label
  ///
  /// In es, this message translates to:
  /// **'Último respaldo: {date}'**
  String lastBackup(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
