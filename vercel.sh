#!/bin/bash
set -e

if [ ! -d "flutter" ]; then
  git clone -b stable https://github.com/flutter/flutter.git --depth 1
fi

export PATH="$PATH:$(pwd)/flutter/bin"
flutter config --enable-web
flutter pub get
flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# Vercel expects output in 'public' directory
rm -rf public
mkdir public
cp -r build/web/* public/
