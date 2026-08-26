# HealthPH+ Frontend

This folder is reserved for frontend clients.

## Current Flutter Client

The current Flutter mobile application still lives at the repository root:

```text
lib/
assets/
android/
ios/
web/
macos/
windows/
linux/
pubspec.yaml
```

I did not move those files automatically because Flutter projects contain platform-specific generated paths and IDE metadata that can break if moved without a coordinated migration.

## Target Workspace Structure

The intended repository structure is:

```text
HealthPH_Plus/
  frontend/
    mobile-flutter/
      lib/
      assets/
      android/
      ios/
      pubspec.yaml

  backend/
    app/
    requirements.txt
    Dockerfile
```

When you are ready for the physical migration, move the Flutter app into `frontend/mobile-flutter/`, then run:

```bash
cd frontend/mobile-flutter
flutter clean
flutter pub get
flutter analyze
```

For now, the backend is already separated in `backend/`.
