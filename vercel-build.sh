#!/bin/bash

# 1. تحميل نسخة فلاتر المستقرة بشكل آمن
echo "Downloading Flutter..."
curl -L -o flutter.tar.xz "https://googleapis.com"

# 2. فك الضغط
echo "Extracting Flutter..."
tar xf flutter.tar.xz

# 3. تفعيل الويب وبناء المشروع
echo "Building Flutter Web..."
./flutter/bin/flutter config --enable-web
./flutter/bin/flutter build web --release

echo "Build Completed Successfully!"

mkdir -p web && cp -r build/web/* web/

