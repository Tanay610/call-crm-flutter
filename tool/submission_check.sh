#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] flutter clean"
flutter clean

echo "[2/5] flutter pub get"
flutter pub get

echo "[3/5] build_runner (Hive adapters)"
dart run build_runner build --delete-conflicting-outputs

echo "[4/5] flutter test"
flutter test

echo "[5/5] build APK"
flutter build apk --release --split-per-abi

echo "Done. APKs in: build/app/outputs/flutter-apk/"

