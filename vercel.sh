#!/bin/bash
if [ ! -d "flutter" ]; then
  git clone -b stable https://github.com --depth 1
fi
./flutter/bin/flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
