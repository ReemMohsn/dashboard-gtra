#!/usr/bin/env bash
set -euo pipefail

FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
git config --global --add safe.directory "$FLUTTER_DIR"

flutter config --no-analytics
flutter pub get

if [ -n "${API_BASE_URL:-}" ]; then
  flutter build web --release --dart-define="API_BASE_URL=$API_BASE_URL"
else
  flutter build web --release
fi
