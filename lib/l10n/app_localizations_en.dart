// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tank Up';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get averageConsumption => 'Average consumption';

  @override
  String get addAtLeastOneRefuel => 'Add at least 1 refuel';

  @override
  String get addRefuel => 'Add refuel';

  @override
  String get refuelAddedSuccessfully => 'Refuel added successfully';

  @override
  String get reset => 'Reset';

  @override
  String get resetZoom => 'Reset zoom';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get history => 'History';

  @override
  String get sort => 'Sort';

  @override
  String get sortDate => 'Date';

  @override
  String get sortConsumption => 'Consumption';

  @override
  String get sortDistance => 'Distance';

  @override
  String get sortLiters => 'Liters';

  @override
  String get filterByDate => 'Filter by date';

  @override
  String get dateFrom => 'From';

  @override
  String get dateTo => 'To';

  @override
  String get selectDate => 'Select';

  @override
  String get clear => 'Clear';

  @override
  String get apply => 'Apply';

  @override
  String get noRefuelsRegistered => 'No refuels registered.';

  @override
  String get noRefuelsInRange => 'No refuels in that date range.';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get confirmDeleteAll =>
      'Are you sure you want to delete all records? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String deletedRecords(int count) {
    return 'Deleted $count records';
  }

  @override
  String get undo => 'Undo';

  @override
  String get deleteRefuel => 'Delete refuel';

  @override
  String confirmDeleteRefuel(String date, String consumption) {
    return 'Delete the refuel from $date ($consumption L/100km)?';
  }

  @override
  String get refuelDeleted => 'Refuel deleted';

  @override
  String get deleteAllRecords => 'Delete all records';

  @override
  String get editRefuel => 'Edit refuel';

  @override
  String get date => 'Date';

  @override
  String get distanceKm => 'Distance (km)';

  @override
  String get required => 'Required';

  @override
  String get invalid => 'Invalid';

  @override
  String get mustBeGreaterThanZero => 'Must be > 0';

  @override
  String get liters => 'Liters';

  @override
  String get commentOptional => 'Comment (optional)';

  @override
  String get addNote => 'Add a note';

  @override
  String get update => 'Update';

  @override
  String get save => 'Save';

  @override
  String get enterDistance => 'Enter the trip distance';

  @override
  String get invalidNumericValue => 'Invalid numeric value';

  @override
  String get mustBeGreaterThanZeroFull => 'Must be greater than 0';

  @override
  String get litersRefueled => 'Liters refueled';

  @override
  String get enterLiters => 'Enter the liters';

  @override
  String get addNoteFull => 'Add a note about this refuel';

  @override
  String get saveRefuel => 'Save refuel';

  @override
  String get deleteRefuelTooltip => 'Delete refuel';

  @override
  String get editRefuelTooltip => 'Edit refuel';

  @override
  String get addRefuelsToSeeChart =>
      'Add refuels to see consumption evolution.';

  @override
  String get consumptionEvolution => 'Consumption evolution';

  @override
  String get legendConsumption => 'Consumption';

  @override
  String get legendMean => 'Average';

  @override
  String get legendAo5 => 'Avg5';

  @override
  String get noVisibleLines => 'No visible lines. Tap a legend to show it.';

  @override
  String get customizeTheme => 'Customize theme';

  @override
  String get accentColor => 'Accent color';

  @override
  String get visualMode => 'Visual mode';

  @override
  String get lightMode => 'Light';

  @override
  String get darkMode => 'Dark';

  @override
  String get systemMode => 'System';

  @override
  String get settingsPersist =>
      'Changes are saved and persist between sessions.';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get catalan => 'Català';

  @override
  String get unrealisticDistance => 'Unrealistic distance (max 5000 km)';

  @override
  String get unrealisticLiters => 'Unrealistic liters (max 200 L)';

  @override
  String get retry => 'Retry';

  @override
  String get exportData => 'Export data';

  @override
  String get exportDataDescription => 'Export refuel history as a CSV file.';

  @override
  String get exportDataCsv => 'Export CSV';

  @override
  String get exportDataSuccess => 'File exported';

  @override
  String get exportDataError => 'Export error';

  @override
  String get googleAccount => 'Google Account';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String signedInAs(String email) {
    return 'Signed in: $email';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get backupData => 'Backup data';

  @override
  String get backupDataDescription =>
      'Save a backup of your history to Google Drive.';

  @override
  String get backupButton => 'Backup';

  @override
  String get backupSuccess => 'Data backed up successfully';

  @override
  String backupError(String error) {
    return 'Backup error: $error';
  }

  @override
  String get restoreData => 'Restore data';

  @override
  String get restoreDataDescription =>
      'Restore your history from Google Drive.';

  @override
  String get restoreButton => 'Restore';

  @override
  String get restoreConfirm =>
      'Restore data? Your current data will be replaced.';

  @override
  String get restoreSuccess => 'Data restored successfully';

  @override
  String restoreError(String error) {
    return 'Restore error: $error';
  }

  @override
  String get noBackupFound => 'No backup found. Create a backup first.';

  @override
  String get signInRequired => 'Sign in with Google to backup your data.';

  @override
  String get driveScopeRequired =>
      'Grant Google Drive permission to backup your data.';

  @override
  String get confirmReplaceData =>
      'Your current data will be replaced by the backup.';

  @override
  String lastBackup(String date) {
    return 'Last backup: $date';
  }

  @override
  String get importData => 'Import data';

  @override
  String get importDataDescription => 'Import refuel history from a CSV file.';

  @override
  String get importDataCsv => 'Import CSV';

  @override
  String importDataSuccess(int count) {
    return 'Imported $count refuels';
  }

  @override
  String get importDataError => 'Import error';

  @override
  String get settings => 'Settings';

  @override
  String get viewHistory => 'View history';

  @override
  String get totalKm => 'Total distance';

  @override
  String get totalLiters => 'Total liters';

  @override
  String get bestFillUp => 'Best';

  @override
  String get worstFillUp => 'Worst';

  @override
  String get emptyStateTitle => 'No refuels yet';

  @override
  String get emptyStateSubtitle => 'Add your first refuel to start tracking';

  @override
  String get discardChanges => 'Discard changes?';

  @override
  String get discardChangesMessage => 'Unsaved changes will be lost.';

  @override
  String get discard => 'Discard';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String recordCount(int count) {
    return '$count records';
  }

  @override
  String get searchComments => 'Search comments...';

  @override
  String get noResults => 'No results';

  @override
  String get about => 'About';

  @override
  String get licenses => 'Licenses';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get pinchToZoom => 'Pinch to zoom';

  @override
  String get zoomFitScreen => 'Fit to screen';

  @override
  String get resetZoomTooltip => 'Reset zoom';

  @override
  String get moreOptions => 'More options';

  @override
  String get importConfirmTitle => 'Import data?';

  @override
  String importConfirmMessage(int count) {
    return '$count refuels will be imported from the file.';
  }

  @override
  String get import => 'Import';

  @override
  String get swipeHint => 'Swipe to delete';
}
