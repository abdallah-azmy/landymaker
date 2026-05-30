#!/bin/bash
# vercel.sh - Robust build script for Flutter Web on Vercel

set -e # Exit immediately if a command exits with a non-zero status
set -x # Print commands and their arguments as they are executed

echo "--- STARTING BUILD ---"

# 1. Environment Check
echo "Current directory: $(pwd)"
# We check if variables are set without printing their actual values for security
echo "Environment variables check: SUPABASE_URL is ${SUPABASE_URL:+set}, SUPABASE_ANON_KEY is ${SUPABASE_ANON_KEY:+set}"

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "ERROR: SUPABASE_URL or SUPABASE_ANON_KEY is not set in Vercel Environment Variables."
  echo "Please add them in Vercel Dashboard -> Project Settings -> Environment Variables."
  exit 1
fi

# 2. Clone Flutter SDK
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK (stable branch)..."
  git clone -b stable https://github.com/flutter/flutter.git --depth 1
else
  echo "Flutter SDK already exists, skipping clone."
fi

# 3. Setup Path
export PATH="$PATH:$(pwd)/flutter/bin"
echo "Flutter path added to PATH."

# 4. Configure and Verify Flutter
echo "Checking Flutter version..."
flutter --version

echo "Enabling Web support..."
flutter config --enable-web

# 5. Dependencies
echo "Running flutter pub get..."
flutter pub get

# 6. Build
echo "Building Flutter Web (Release)..."
# The variables $SUPABASE_URL and $SUPABASE_ANON_KEY must be defined in Vercel Dashboard
flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --base-href /

# 7. Prepare Output
echo "Preparing 'public' directory..."
rm -rf public
mkdir -p public

if [ -d "build/web" ]; then
  echo "Copying build artifacts to 'public'..."
  cp -r build/web/* public/
else
  echo "ERROR: build/web directory was not created!"
  exit 1
fi

# 8. Verification
echo "Verifying 'public' directory contents:"
ls -la public

echo "--- BUILD FINISHED SUCCESSFULLY ---"
exit 0
