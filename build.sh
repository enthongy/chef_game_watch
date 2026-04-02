#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "1. Cloning Flutter stable branch..."
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

echo "Adding git safe directories to prevent ownership issues..."
git config --global --add safe.directory '*'

echo "2. Adding Flutter to PATH..."
export PATH="$PATH:`pwd`/flutter/bin"

echo "Disabling Flutter telemetry to avoid prompt on Vercel..."
flutter config --no-analytics || true
flutter --disable-telemetry || true

echo "3. Removing base href from index.html (Vercel serves from root/)..."
sed -i 's|<base href=".*">|<base href="/">|g' web/index.html

echo "4. Building Flutter Web App..."
flutter build web --release

echo "5. Build completed successfully!"
