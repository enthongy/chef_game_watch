#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "1. Cloning Flutter stable branch..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

echo "2. Adding Flutter to PATH..."
export PATH="$PATH:`pwd`/flutter/bin"

echo "3. Removing base href from index.html (Vercel serves from root/)..."
# Just to be safe, making sure we don't accidentally have a sub-path in base href 
# which is often used for GitHub Pages but breaks Vercel
sed -i 's|<base href=".*">|<base href="/">|g' web/index.html

echo "4. Building Flutter Web App..."
flutter build web --release

echo "5. Build completed successfully!"
