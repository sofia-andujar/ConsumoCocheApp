# Excel Import Helper

This helper allows you to import a one-time Excel spreadsheet into a SQLite database file compatible with the app.

## Usage

1. Export your refill data into an Excel file (`.xlsx`).
2. Make sure the first row contains headers exactly:
   - `date`
   - `kilometers`
   - `liters`
3. Run the import script:

```bash
flutter pub get
dart run tool/import_excel.dart path/to/data.xlsx repostajes.db --force
```

4. Copy the generated `repostajes.db` file into the app's data folder.

## App database location

For the app to use the file, it must be placed where `getApplicationDocumentsDirectory()` resolves.

On Windows desktop debug builds, this is usually:

```text
%APPDATA%\calculadora_consumo_app\repostajes.db
```

If you are running on a mobile emulator, copy the file to the device using the appropriate tooling (`adb push` for Android, Simulator file access for iOS).

## Notes

- This script is intended for a one-time manual import and is not part of the app UI.
- The app schema is:
  - `id` INTEGER PRIMARY KEY AUTOINCREMENT
  - `date` TEXT NOT NULL
  - `kilometers` REAL NOT NULL
  - `liters` REAL NOT NULL
