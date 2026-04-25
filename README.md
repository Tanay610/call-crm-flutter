# Call CRM App (Assessment)

Production-ready **Call Recording + Basic CRM** built with Flutter + Riverpod + Hive.

## What’s implemented (the 2 tasks)

1) **CRM (Customer Management)**
- Full CRUD: name, phone, email, company, optional avatar field (metadata)
- Search by name/phone/company
- Sorting: **last called**, **most recorded**, **newest**
- Delete customer with **cascade deletion** of their recordings (Hive + files)
- Customer detail screen shows **call history list**

2) **Call Recording**
- “Active call” screen (simulated call UI)
- Record with **live waveform** (`audio_waveforms`)
- Pause/resume, stop
- Auto-save to local storage (AAC in `.m4a`)
- Playback: play/pause/seek + speed (0.5x/1x/1.5x/2x)
- Show duration, size, recorded date
- Delete from UI (also deletes audio file)
- Export/share via platform share sheet (`share_plus`)

## Setup

Prereqs:
- Flutter `3.38+` (this repo is tested with Flutter `3.38.7`, Dart `3.10.7`)
- Android Studio / Xcode set up for your machine

Commands:
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run
```

Build APK:
```bash
flutter build apk --release --split-per-abi
```

Submission checklist helper:
```bash
chmod +x tool/submission_check.sh
./tool/submission_check.sh
```

## Architecture (Clean Architecture)

Folder layout:
```
lib/
  core/            # theme, constants, DI, utils
  data/            # Hive models/datasources, file storage, mock remote API
  domain/          # entities, repository interfaces, usecases
  presentation/    # Riverpod providers, pages, widgets
```

ASCII diagram:
```
presentation  --->  domain  <---  data
   |                 |             |
   |           usecases/interfaces |
   |                 |             |
   +---- Riverpod ----+     Hive + FS + Dio(Mock)
```

Why Riverpod:
- Simple, testable DI + state; async loading/error states are first-class (`AsyncValue`)
- Great fit for “local-first” apps with multiple independent controllers (customers, recordings, audio)

## Local Storage

Metadata: **Hive**
- Customers: `id, name, phone, email, company, createdAt, updatedAt`
- Recordings: `id, customerId, filePath, duration, size, recordedAt, synced`

Audio files: **File system**
- Path: `Documents/recordings/{customerId}/{recordingId}.m4a`

## Permissions

Runtime permissions (handled with rationale + retry/settings redirect):
- Microphone (`RECORD_AUDIO` / `NSMicrophoneUsageDescription`)
- Storage (Android; recordings are saved locally)

## Mock API (local-first sync)

Domain contract: `lib/domain/repositories/recording_api.dart`
- `uploadRecording(File file)`
- `syncRecordings()`

Fake implementation: `lib/data/remote/mock_recording_api.dart`
- Simulates **2s** delay
- **10% random failure** (to validate retry/error UX)

Retrofit contract (for swapping to a real backend later): `lib/data/remote/recording_api_client.dart`
- Uses `dio + retrofit` annotations
- Current repo uses the mock API for behavior; swap by providing a real `RecordingApi` implementation in `lib/core/di/providers.dart`

## Tests

Passing tests (run with `flutter test`):
- Use case: `test/domain/add_customer_test.dart`
- Use case: `test/domain/delete_customer_test.dart`
- Provider/controller: `test/presentation/customers_controller_test.dart`

## CI/CD

GitHub Actions workflow builds APK + runs tests:
- `.github/workflows/android_apk.yml`

## Screenshots / GIF (required for submission)

Add screenshots/GIF here once captured:
- `docs/screenshots/home.png`
- `docs/screenshots/customer_detail.png`
- `docs/screenshots/call_recording_view.png`
- `docs/screenshots/search_cutomer_view.png`

## APK Download Link (required for submission)

- Release/APK link: **TODO**

## Live Demo Link (optional)

- Demo link: **TODO**
