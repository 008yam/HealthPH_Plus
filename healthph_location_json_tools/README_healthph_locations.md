# HealthPH+ Philippine Location JSON Generator

This package contains a generator script for Philippine administrative location JSON files usable in Flutter.

## Files

- `healthph_location_dataset_generator.py` - downloads PSGC data and generates JSON files.
- `healthph_location_service_example.dart` - sample Flutter loader service.

## How to Use

1. Put `healthph_location_dataset_generator.py` in the root of your Flutter project.
2. Run:

```bash
python3 healthph_location_dataset_generator.py
```

3. It will create:

```text
assets/data/locations/
├── regions.json
├── provinces.json
├── cities_municipalities.json
├── barangays.json
├── philippines_full.json
└── barangays_by_region/
```

4. Add this to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/data/locations/
    - assets/data/locations/barangays_by_region/
```

5. Run:

```bash
flutter pub get
```

6. Use the sample `LocationDataService` to load JSON files inside Flutter.

## Recommended Use in HealthPH+

Use these JSON files for:

- Region dropdowns
- Province dropdowns
- City/Municipality dropdowns
- Barangay dropdowns
- Data Collection location fields
- Disease Watch filters
- Map Surveillance filters

## Note

The generated `philippines_full.json` can be large. For faster mobile performance, prefer loading:

- `regions.json`
- `provinces.json`
- `cities_municipalities.json`
- `barangays_by_region/<REGION_CODE>.json`

instead of loading the full hierarchy at app startup.
